// Default parameters passed from the seed job or used as fallback
def GIT_REPO   = binding.hasVariable('GIT_REPO')   ? binding.getVariable('GIT_REPO')   : 'https://github.com/HomeAssignment2025/DSL_Jenkins_CICD.git'
def GIT_BRANCH = binding.hasVariable('GIT_BRANCH') ? binding.getVariable('GIT_BRANCH') : 'main'
def IMAGE_TAG  = binding.hasVariable('IMAGE_TAG')  ? binding.getVariable('IMAGE_TAG')  : 'latest'

// -----------------------------
// Job #1: Build Flask API Image
// -----------------------------
pipelineJob('build-flask-api') {
    description('Builds and pushes a Docker image for the Flask API')
    parameters {
        stringParam('GIT_REPO', GIT_REPO, 'Git repository containing the Flask API')
        stringParam('GIT_BRANCH', GIT_BRANCH, 'Branch to checkout')
        stringParam('IMAGE_TAG', IMAGE_TAG, 'Tag to apply to the Docker image')
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(GIT_REPO) }
                    branch(GIT_BRANCH)
                }
            }
            scriptPath('flask-api/Jenkinsfile')
        }
    }
}

// ---------------------------------
// Job #2: Build Nginx Proxy Image
// ---------------------------------
pipelineJob('build-nginx-proxy') {
    description('Builds and pushes a customized Nginx proxy Docker image')
    parameters {
        stringParam('GIT_REPO', GIT_REPO, 'Git repository containing Nginx proxy Dockerfile and config')
        stringParam('GIT_BRANCH', GIT_BRANCH, 'Branch to checkout')
        stringParam('IMAGE_TAG', IMAGE_TAG, 'Tag to apply to the Docker image')
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(GIT_REPO) }
                    branch(GIT_BRANCH)
                }
            }
            scriptPath('nginx-proxy/Jenkinsfile')
        }
    }
}

// ----------------------------------------------
// Job #3: Runner Job to Deploy and Test Locally
// ----------------------------------------------
pipelineJob('runner-job') {
    description('Runs Flask and Nginx containers locally, sends request, and validates the response')
    parameters {
        stringParam('GIT_REPO', GIT_REPO, 'Git repository')
        stringParam('GIT_BRANCH', GIT_BRANCH, 'Branch to checkout')
        stringParam('IMAGE_TAG', IMAGE_TAG, 'Tag used for Docker images')
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote { url(GIT_REPO) }
                    branch(GIT_BRANCH)
                }
            }
            scriptPath('runner-job/Jenkinsfile')
        }
    }
}



// def defaultRepo = 'https://github.com/HomeAssignment2025/DSL_Jenkins_CICD.git'
// def defaultBranch = '*/main'
// def defaultTag = 'latest'

// def pipelineJobs = [
//     [
//         name: 'build-python-api',
//         description: 'Builds and pushes the Flask Docker image',
//         scriptPath: 'flask-api/Jenkinsfile'
//     ],
//     [
//         name: 'build-nginx-proxy',
//         description: 'Builds and pushes the Nginx reverse proxy image',
//         scriptPath: 'nginx-proxy/Jenkinsfile'
//     ],
//     [
//         name: 'run-local-containers',
//         description: 'Runs both containers and verifies proxy -> Flask communication',
//         scriptPath: 'runner-job/Jenkinsfile'
//     ]
// ]

// pipelineJobs.each { jobDef ->
//     pipelineJob(jobDef.name) {
//         description(jobDef.description)

//         parameters {
//             stringParam('BRANCH_NAME', defaultBranch, 'Git branch to build')
//             stringParam('DOCKER_IMAGE_TAG', defaultTag, 'Docker image tag')
//         }

//         definition {
//             cpsScm {
//                 scm {
//                     git {
//                         remote {
//                             url(defaultRepo)
//                         }
//                         branches('$BRANCH_NAME')
//                     }
//                 }
//                 scriptPath(jobDef.scriptPath)
//             }
//         }

//         logRotator {
//             daysToKeep(14)
//             numToKeep(25)
//         }

//         disabled(false)
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
// //                 // In the future, integrate tools like SonarQube, Checkstyle, etc.
// //             }
// //         }

// //         stage('Unit Tests') {
// //             steps {
// //                 echo '[INFO] Running unit tests for DSL scripts (placeholder)...'
// //                 // Later, add Groovy class validation or DSL verification here
// //             }
// //         }

// //         stage('Generate Pipeline Jobs') {
// //             steps {
// //                 echo '[INFO] Generating Jenkins pipeline jobs using Job DSL...'
// //                 script {
// //                     def pipelineJobs = [
// //                         [
// //                             name: 'build-python-api',
// //                             description: 'Builds and pushes the Flask Docker image',
// //                             scriptPath: 'flask-api/Jenkinsfile'
// //                         ],
// //                         [
// //                             name: 'build-nginx-proxy',
// //                             description: 'Builds and pushes the Nginx reverse proxy image',
// //                             scriptPath: 'nginx-proxy/Jenkinsfile'
// //                         ],
// //                         [
// //                             name: 'run-local-containers',
// //                             description: 'Runs both containers and verifies proxy -> Flask communication',
// //                             scriptPath: 'runner-job/Jenkinsfile'
// //                         ]
// //                     ]

// //                     pipelineJobs.each { jobDef ->
// //                         jobDsl scriptText: """
// //                             pipelineJob('${jobDef.name}') {
// //                                 description('${jobDef.description}')
// //                                 parameters {
// //                                     stringParam('BRANCH_NAME', '${DEFAULT_BRANCH}', 'Git branch to build')
// //                                     stringParam('DOCKER_IMAGE_TAG', '${DEFAULT_TAG}', 'Docker image tag')
// //                                 }
// //                                 definition {
// //                                     cpsScm {
// //                                         scm {
// //                                             git {
// //                                                 remote {
// //                                                     url('${DEFAULT_REPO}')
// //                                                 }
// //                                                 branches('\$BRANCH_NAME')
// //                                             }
// //                                         }
// //                                         scriptPath('${jobDef.scriptPath}')
// //                                     }
// //                                 }
// //                                 logRotator {
// //                                     daysToKeep(14)
// //                                     numToKeep(25)
// //                                 }
// //                                 disabled(false)
// //                             }
// //                         """
// //                     }
// //                 }
// //             }
// //         }

// //         stage('Teardown') {
// //             steps {
// //                 echo '[INFO] Performing cleanup and final reporting (placeholder)...'
// //                 // Add artifact cleanup or reporting tools if needed
// //             }
// //         }
// //     }

// //     post {
// //         success {
// //             echo '[SUCCESS] All seed job stages completed successfully.'
// //         }
// //         failure {
// //             echo '[FAILURE] One or more seed job stages failed.'
// //         }
// //     }
// // }


// // def defaultRepo = 'https://github.com/HomeAssignment2025/DSL_Jenkins_CICD.git'
// // def defaultBranch = '*/main'
// // def defaultTag = 'latest'

// // def pipelineJobs = [
// //     [
// //         name: 'build-python-api',
// //         description: 'Builds and pushes the Flask Docker image',
// //         scriptPath: 'flask-api/Jenkinsfile'
// //     ],
// //     [
// //         name: 'build-nginx-proxy',
// //         description: 'Builds and pushes the Nginx reverse proxy image',
// //         scriptPath: 'nginx-proxy/Jenkinsfile'
// //     ],
// //     [
// //         name: 'run-local-containers',
// //         description: 'Runs both containers and verifies proxy -> Flask communication',
// //         scriptPath: 'runner-job/Jenkinsfile'
// //     ]
// // ]

// // pipelineJobs.each { jobDef ->
// //     pipelineJob(jobDef.name) {
// //         description(jobDef.description)

// //         parameters {
// //             stringParam('BRANCH_NAME', defaultBranch, 'Git branch to build')
// //             stringParam('DOCKER_IMAGE_TAG', defaultTag, 'Docker image tag')
// //         }

// //         definition {
// //             cpsScm {
// //                 scm {
// //                     git {
// //                         remote {
// //                             url(defaultRepo)
// //                         }
// //                         branches('$BRANCH_NAME')
// //                     }
// //                 }
// //                 scriptPath(jobDef.scriptPath)
// //             }
// //         }

// //         logRotator {
// //             daysToKeep(14)
// //             numToKeep(25)
// //         }

// //         // Removed properties { pipelineTriggers { scm(...) } } to avoid Job DSL error
// //         disabled(false)
// //     }
// // }
