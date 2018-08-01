def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
    // containerTemplate(name: 'gradle', image: 'gradle:4.9-jdk8-alpine', command: 'cat'. ttyEnabled: true),
    containerTemplate(name: 'elixir', image: 'elixir:1.7.1-alpine', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true),
    containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
  ],
  volumes: [
    hostPathVolume(mountPath: '/home/gradle/.gradle', hostPath: '/tmp/jenkins/.gradle'),
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
  ]) {
    node(label) {
      def myRepo = checkout scm
      def projectName = 'kemisten'
      def gitCommit = myRepo.GIT_COMMIT
      def gitBranch = myRepo.GIT_BRANCH
      def shortGitCommit = "${gitCommit[0..10]}"
      def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
      def dockerImageRepo = build.getEnvironment(listener).get('ACR_LOGINSERVER')

      // stage('Test') {
      //   try {
      //     container('gradle') {
      //       sh """
      //       pwd
      //       echo "GIT_BRANCH=${gitBranch}" >> /etc/environment
      //       echo "GIT_COMMIT=${gitCommit}" >> /etc/environment
      //       """
      //     } catch (exc) {
      //       println "Failed to test - ${currentBuild.fullDisplayName}"
      //       throw(exc)
      //     }
      //   }
      // }
      // stage('Build') {
      //   container('gradle') {
      //     sh "gradle build"
      //   }
      // }
      stage('Test') {
        try {
          container('elixir') {
            sh """
            mix test
            """
          }
        } catch (exc) {
          println "Failed to test - ${currentBuild.fullDisplayName}"
          throw(exc)
        }
      }

      // stage('Create Docker images') {
      //   container('docker') {
      //     withCredentials([[$class: 'UsernamePasswordMultiBinding',
      //       credentialsId: 'menuan-acr-credentials',
      //       usernameVariable: 'DOCKER_HUB_USER',
      //       passwordVariable: 'DOCKER_HUB_PASSWORD']]) {
      //         sh """
      //         docker login ${dockerImageRepo} -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASSWORD}
      //         docker build -t ${dockerImageRepo}/${projectName}:${gitCommit} .
      //         docker push ${dockerImageRepo}/${projectName}:${gitCommit}
      //         """
      //     }
      //   }
      // }
      // stage('Run kubectl') {
      //   container('kubectl') {
      //     sh "kubectl get pods"
      //   }
      // }
      // stage('Run helm') {
      //   container('helm') {
      //     sh "helm list"
      //   }
      // }
    }
  }
