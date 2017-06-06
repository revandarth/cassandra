#!groovy


@Library('jenkins-shared-library') _

/**
* Following environment variables need to be set in job configuration,
*
* SLAVE=<Jenkins Slave>
* CONTAINERHUB_URL=<CONTAINER HUB URL>
* PROJECT_NAME=<CAE PROJECT NAME>
* IMAGE_REPO=<DOCKER IMAGE REPO>
* SERVICE=<SERVICE_NAME>
* OPS_SPARK_ROOM_ID=<OPS TEAM SPARK ROOM ID>
* DEV_SPARK_ROOM_ID=<DEV TEAM SPARK ROOM ID>
*/

import groovy.json.JsonOutput
def slave= "sjc_linux_team_OneIdentity_slv_1"
def CONTAINERHUB_URL=env.CONTAINERHUB_URL
def OPS_SPARK_ROOM_ID="Y2lzY29zcGFyazovL3VzL1JPT00vZmY4ZDc0ZTAtMzBmOS0xMWU3LWE5Y2EtYjUyNjgwMGQ4MTFi"
def DEV_SPARK_ROOM_ID="Y2lzY29zcGFyazovL3VzL1JPT00vOWNlOGQ0ZGQtN2MxNi0zMmZiLTgxMmItOWEyZWExOWFlNzJj"
def IMAGE =env.IMAGE
def service = env.SERVICE
def project=env.PROJECT_NAME
def environment = "poc"
def COMMIT_ID
def IMAGE_TAG // depends on the branch.
def message // for spark notification
def jStage //


Properties props

echo "DEBUG: Slave Node: ${slave}"
echo "DEBUG: CONTAINERHUB_URL- ${CONTAINERHUB_URL}"
echo "DEBUG: OPS_SPARK_ROOM_ID- ${OPS_SPARK_ROOM_ID}"
echo "DEBUG: DEV_SPARK_ROOM_ID- ${DEV_SPARK_ROOM_ID}"
try {
node(slave){
       deleteDir() // To wipe out Workspace

      stage 'Build Initialize'
              jStage ="Initialize"
              message = service
              coiNotify.sparkNotification(DEV_SPARK_ROOM_ID, jStage, "SUCCESSFUL", message)


      stage 'Checkout'
              jStage = "Checkout"
              echo "INFO: Checkout the source on ${slave} slave"
              checkout scm
              echo "INFO: Checkout the source code is done"

              COMMIT_ID = coiUtils.getGitsha()
              echo "COMMIT_ID: ${COMMIT_ID}"

              coiNotify.bitBucketNotification("INPROGRESS", COMMIT_ID)

              //  environment = coiUtils.getEnvironmentFromBranchName(env.BRANCH_NAME) // StaticMethod is not allowed - Todo
              echo "DEBUG: environment - ${environment}"
              message = "Code Chekout Completed for ${service}"
              coiNotify.sparkNotification(DEV_SPARK_ROOM_ID, jStage, "SUCCESSFUL", message)

      stage 'DockerBuild And Publish'
              jStage = "DockerBuild and Publish"

              // props = coiEnv.getEnvProperties(project, service) // ONEIDENT-3108- Error reading properties file data using ByteArrayInputStream -Todo

              echo "INFO: Getting branch name from jenkins environment variables"
              // IMAGE=props."containerhub.repo" // Todo- ONEIDENT-3108

              def branch=coiUtils.getImageTag(env.BRANCH_NAME)
              IMAGE_TAG=branch+"-"+env.BUILD_NUMBER

              echo "DEBUG: IMAGE: ${IMAGE}"
              echo "DEBUG: IMAGE TAG- ${IMAGE_TAG}"
              echo "DEBUG: CONTAINERHUB_URL- ${CONTAINERHUB_URL}"

              if(!IMAGE || !IMAGE_TAG && !CONTAINERHUB_URL){
                  currentBuild.result = 'FAILURE'
                  echo "ERROR: Image build information are not valid. Check following, IMAGE: ${IMAGE}, IMAGE_TAG: ${IMAGE_TAG}, CONTAINERHUB_URL: ${CONTAINERHUB_URL}"
                  throw new Exception("ERROR: Image build information are not valid. Check following, IMAGE: ${IMAGE}, IMAGE_TAG: ${IMAGE_TAG}, CONTAINERHUB_URL: ${CONTAINERHUB_URL}")
              }else {
                  docker.withRegistry(CONTAINERHUB_URL, 'CONTAINER_REPO_ID'){
                      echo 'INFO: Building docker image'
                      def app = docker.build "${IMAGE}:${IMAGE_TAG}"
                      echo 'INFO: Pushing docker image to ECH'
                      retry(5) {
                        app.push()
                      }
                  }
              }
              
              message= "Newly built image is published to ECH with new tag ${IMAGE_TAG}"
              coiNotify.sparkNotification(DEV_SPARK_ROOM_ID, jStage, "SUCCESSFUL", message)

              def defaultImageTag = sh(returnStdout: true, script: "cat cae.yaml | grep 'image:' | awk -F: '{print \$3}'").trim()
              echo "DEBUG: Existing Image tag - ${defaultImageTag}"

              echo "INFO: Replacing image tag in cae.yaml"
              if(!defaultImageTag){
                  sh """
                    sed -i "/image:/s/\$/:$IMAGE_TAG/g" cae.yaml
                  """
              }else{
                  
                  sh """
                    sed -i "/image:/s/$defaultImageTag/$IMAGE_TAG/g" cae.yaml
                  """
              }
              def imageTagAfter = sh(returnStdout: true, script: "cat cae.yaml | grep 'image:' | awk -F: '{print \$3}'").trim()

              echo "INFO: IMAGE tag in cae.yaml file after replacing - ${imageTagAfter}"
      stage 'Deploy To CAE poc'
              jStage = "Deploy to POC"
              environment = "poc"
              echo "INFO: Deploying in coi-${project}-${environment}"
             // coiDeploy.runDeploy(["alln", "rcdn"] as String[], project, service, environment, IMAGE_TAG)
              echo "INFO: Deployment is completed at coi-${project}-"
              message="${service} deployment in ${environment} is done"
              coiNotify.sparkNotification(DEV_SPARK_ROOM_ID, jStage, "SUCCESSFUL", message)
} 
}catch(Exception e) {
              currentBuild.result = 'FAILURE'
              def errorMessage = "Failed at ${jStage}: "+e.toString()
              message="${service} is failed to ${jStage} for coi-${project}-${environment}. Platform team has been notified and will investigate as soon as possible"
              coiNotify.handleException(OPS_SPARK_ROOM_ID, DEV_SPARK_ROOM_ID, jStage, message, errorMessage, slave)       
} finally {
        
        jStage = "Job"
        buildStatus = currentBuild.result
        coiNotify.handleFinally(OPS_SPARK_ROOM_ID, DEV_SPARK_ROOM_ID, buildStatus, COMMIT_ID, jStage, slave)

}