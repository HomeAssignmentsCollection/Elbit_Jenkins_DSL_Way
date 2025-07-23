pipeline {
  agent any

  parameters {
    string(name: 'DEFAULT_REPO', defaultValue: 'https://github.com/HomeAssignment2025/DSL_Jenkins_CICD.git', description: 'Git repo URL')
    string(name: 'DEFAULT_BRANCH', defaultValue: '*/main', description: 'Git branch name')
    string(name: 'DEFAULT_TAG', defaultValue: 'latest', description: 'Image tag')
  }

  environment {
    REPO = "${params.DEFAULT_REPO}"
    BRANCH = "${params.DEFAULT_BRANCH}"
    TAG = "${params.DEFAULT_TAG}"
  }

  stages {
    stage('Code Checkout') {
      steps {
        script {
          echo "[INFO] Cloning from ${REPO} branch ${BRANCH}"
          checkout([$class: 'GitSCM',
            branches: [[name: "${BRANCH}"]],
            userRemoteConfigs: [[url: "${REPO}"]]
          ])
        }
      }
    }

    stage('Static Code Analysis') {
      steps {
        echo '[INFO] Running static code analysis (placeholder)...'
      }
    }

    stage('Unit Tests') {
      steps {
        echo '[INFO] Running unit tests for DSL scripts (placeholder)...'
      }
    }

    stage('Generate Pipeline Jobs') {
      steps {
        echo '[INFO] Generating Jenkins pipeline jobs using Job DSL...'
        jobDsl targets: 'job-dsl/jobs.groovy', removedJobAction: 'DELETE'
      }
    }

    stage('Teardown') {
      steps {
        echo '[INFO] Final cleanup and reporting...'
      }
    }
  }

  post {
    success {
      echo '[SUCCESS] Seed job completed successfully.'
    }
    failure {
      echo '[FAILURE] Seed job failed.'
    }
  }
}


// pipeline {
//     agent any

//     environment {
//         DEFAULT_REPO = 'https://github.com/HomeAssignment2025/DSL_Jenkins_CICD.git'
//         DEFAULT_BRANCH = '*/main'
//         DEFAULT_TAG = 'latest'
//     }

//     parameters {
//         string(name: 'GIT_REPO', defaultValue: "${DEFAULT_REPO}", description: 'GitHub repository URL')
//         string(name: 'GIT_BRANCH', defaultValue: 'main', description: 'Branch to checkout')
//         string(name: 'IMAGE_TAG', defaultValue: "${DEFAULT_TAG}", description: 'Default Docker image tag')
//     }

//     stages {
//         stage('Checkout DSL Project') {
//             steps {
//                 echo "[INFO] Checking out seed repo: ${params.GIT_REPO}, branch: ${params.GIT_BRANCH}"
//                 checkout([
//                     $class: 'GitSCM',
//                     branches: [[name: "*/${params.GIT_BRANCH}"]],
//                     userRemoteConfigs: [[url: "${params.GIT_REPO}"]]
//                 ])
//             }
//         }

//         stage('Validate DSL Script (Optional)') {
//             steps {
//                 echo '[INFO] Optionally validate DSL scripts – placeholder'
//                 // you can add groovy script validation here
//             }
//         }

//         stage('Run Job DSL') {
//             steps {
//                 echo '[INFO] Running DSL scripts to create jobs...'
//                 jobDsl(
//                     targets: 'job-dsl/jobs.groovy',
//                     removedJobAction: 'DELETE',
//                     removedViewAction: 'DELETE',
//                     lookupStrategy: 'SEED_JOB',
//                     additionalParameters: [
//                         string(name: 'GIT_REPO', value: "${params.GIT_REPO}"),
//                         string(name: 'GIT_BRANCH', value: "${params.GIT_BRANCH}"),
//                         string(name: 'IMAGE_TAG', value: "${params.IMAGE_TAG}")
//                     ]
//                 )
//             }
//         }

//         stage('Teardown') {
//             steps {
//                 echo '[INFO] Cleanup or final reporting – placeholder'
//             }
//         }
//     }

//     post {
//         success {
//             echo "[SUCCESS] Seed job completed and jobs created!"
//         }
//         failure {
//             echo "[FAILURE] Seed job failed."
//         }
//     }
// }



// // pipeline {
// //     agent any

// //     environment {
// //         DEFAULT_REPO = 'https://github.com/HomeAssignment2025/DSL_Jenkins_CICD.git'
// //         DEFAULT_BRANCH = '*/main'
// //         DEFAULT_TAG = 'latest'
// //     }

// //     stages {
// //         stage('Code Checkout') {
// //             steps {
// //                 echo '[INFO] Checking out DSL seed repository...'
// //                 checkout scm
// //             }
// //         }

// //         stage('Static Code Analysis') {
// //             steps {
// //                 echo '[INFO] Running static code analysis (placeholder)...'
// //                 // Add tools like SonarQube here if needed
// //             }
// //         }

// //         stage('Unit Tests') {
// //             steps {
// //                 echo '[INFO] Running unit tests for DSL scripts (placeholder)...'
// //                 // Validate groovy scripts or DSL syntax
// //             }
// //         }

// //         stage('Generate Pipeline Jobs') {
// //             steps {
// //                 echo '[INFO] Generating Jenkins pipeline jobs using Job DSL...'
// //                 jobDsl targets: 'job-dsl/jobs.groovy', removedJobAction: 'DELETE'
// //             }
// //         }

// //         stage('Teardown') {
// //             steps {
// //                 echo '[INFO] Performing cleanup and final reporting (placeholder)...'
// //                 // Final reporting or archiving logs if needed
// //             }
// //         }
// //     }

// //     post {
// //         success {
// //             echo '[SUCCESS] Seed job completed successfully.'
// //         }
// //         failure {
// //             echo '[FAILURE] Seed job failed.'
// //         }
// //     }
// // }
