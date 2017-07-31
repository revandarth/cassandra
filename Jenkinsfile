#!groovy

@Library('jenkins-shared-library') _

/**
* Following environment variables need to be set in job configuration,
* DEDICATED_SLAVE=<Jenkins Slave>
* CONTAINERHUB_URL=<CONTAINER HUB URL>
* CAE_PROJECT=<CAE_PROJECT>
* CONTAINER_REPO=<DOCKER IMAGE REPO>
* SERVICE=<SERVICE_NAME>
* OPS_SPARK_ROOM_ID=<OPS TEAM SPARK ROOM ID>
* DEV_SPARK_ROOM_ID=<DEV TEAM SPARK ROOM ID>
*/

def jStage //
def promoteTo

Properties props

echo "DEBUG: Slave Node: ${env.DEDICATED_SLAVE}"
echo "DEBUG: CONTAINERHUB_URL- ${env.CONTAINERHUB_URL}"
echo "DEBUG: OPS_SPARK_ROOM_ID- ${env.OPS_SPARK_ROOM_ID}"
echo "DEBUG: DEV_SPARK_ROOM_ID- ${env.DEV_SPARK_ROOM_ID}"
try {
      node(env.DEDICATED_SLAVE){

          deleteDir() // To wipe out Workspace

          stage 'Build Initialize'
                  jStage ="Initialize"
                  def message = env.SERVICE
                  coiNotify.sparkNotification(env.DEV_SPARK_ROOM_ID, jStage, "SUCCESSFUL", message)
          stage 'Checkout'

                  jStage = "Checkout"
                  coiUtils.checkoutSource(jStage)

          stage 'DockerBuild And Publish'
                  jStage = "DockerBuild and Publish"
                  coiBuild.buildDockerImage(jStage)

          stage 'Deploy To CAE POC'
                  jStage = "Deploy to POC"
                  environment = "poc"
                  coiDeploy.runDeploy(["alln", "rcdn"] as String[], environment, jStage)
      } 
      // having input step outside of node, so it doesn't tie up to a slave

      stage 'DEV Promotion Approval'
              jStage="DEV Promotion Approval"
              promoteTo = "dev"
              coiBuild.promotionApproval(jStage, promoteTo)

      node(env.DEDICATED_SLAVE){
          stage 'Deploy To CAE DEV'
              jStage = "Deploy to DEV"
              unstash "cae.yaml"
              environment = "dev"
              coiDeploy.runDeploy(["alln", "rcdn"] as String[], environment, jStage)
      }

      stage 'Stage Promotion Approval'
              jStage="Stage Promotion Approval"
              promoteTo = "stg"
              coiBuild.promotionApproval(jStage, promoteTo)

      node(env.DEDICATED_SLAVE){
          stage 'Deploy To CAE STG'
              jStage = "Deploy to Stg"
              unstash "cae.yaml"
              environment = "stg"
              coiDeploy.runDeploy(["alln", "rcdn"] as String[], environment, jStage)
      }
      stage 'Prod Promotion Approval'
              jStage="Prod Promotion Approval"
              promoteTo = "prd"
              coiBuild.promotionApproval(jStage, promoteTo)

      node(env.DEDICATED_SLAVE){
          stage 'Deploy To CAE Prd'
              jStage = "Deploy to Prod"
              unstash "cae.yaml"
              environment = "prd"
              coiDeploy.runDeploy(["alln", "rcdn"] as String[], environment, jStage)
        }     

}catch(Exception e) {
        currentBuild.result = 'FAILURE'
        coiUtils.handleException(jStage, e.toString())
     
} finally {
        coiNotify.handleFinally()
}