nodeType = 'bionic_jenkins'

node(nodeType) {
    ws('workspace/hive') {
        env.PATH = "/var/lib/jenkins/bin:${env.PATH}"

        try {
            stage('Checkout source') {
                checkout scm
                sh('git rev-parse HEAD > .commit')
                env.GIT_COMMIT = readFile('.commit').trim()
                sh('git rev-parse --short HEAD > .commit')
                env.SHORT_COMMIT = readFile('.commit').trim()
                sh('git log -1 --pretty=%s > .commit')
                env.GIT_COMMIT_MESSAGE = readFile('.commit').trim()
                sh("git show -s --format='%an' $env.GIT_COMMIT > .commit")
                env.GIT_COMMIT_AUTHOR = readFile('.commit').trim()
                sh('rm -f .commit')
                env.GIT_COMMIT_URL = "https://github.com/6si/hive/commit/${env.GIT_COMMIT}/"

                // setting this for bazel use
                sh('echo $BRANCH_NAME > .branch_name')
                sh('echo $(echo $BRANCH_NAME | awk -F\'env/\' \'{ if  ($1 == "6si-main") {$2 = "prod"} else if ($1 == "staging") {$2 = "staging"} else {$2 = "dev"}; print $2 }\') > .env_type')
                env.SIXSENSE_ENV=readFile('.env_type').trim()
                sh('echo $(echo $BRANCH_NAME | awk -F\'env/\' \'{ if  ($1 == "6si-main" || $1 == "staging" || length($1) == 0) {$2 = "yes"} else {$2 = "no"}; print $2 }\') > .env_buildable')
                env.BUILDABLE=readFile('.env_buildable').trim()
            }

            stage('Maven build and test') {
                sh '''
                    mvn clean package -Pdist
                '''
            }

            stage('Deploy to S3') {
                sh '''
                    if [ "$SIXSENSE_ENV" = "prod" ]; then
                      # aws s3 sync <target/> s3://<target>
                    if
                '''
            }

            slackSend color: "good",
                      message: "Success: ${env.GIT_COMMIT_AUTHOR}'s build for <${env.JOB_URL}|${env.BRANCH_NAME}> (<${env.BUILD_URL}|${env.BUILD_DISPLAY_NAME}>)\n- ${env.GIT_COMMIT_MESSAGE} (<${env.GIT_COMMIT_URL}|${env.SHORT_COMMIT}>)"
        }
        catch (err) {
            slackSend color: "danger", message: "Failed: ${env.GIT_COMMIT_AUTHOR}'s build for <${env.JOB_URL}|${env.BRANCH_NAME}> (<${env.BUILD_URL}|${env.BUILD_DISPLAY_NAME}>)\n- Error: $err\n- ${env.GIT_COMMIT_MESSAGE} (<${env.GIT_COMMIT_URL}|${env.SHORT_COMMIT}>)"
            currentBuild.result = 'FAILURE'
        }

        stage('Cleanup') {
            deleteDir()
        }
    }
}