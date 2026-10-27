def check(String name, Closure body) {
  publishChecks name: name, status: 'IN_PROGRESS'
  try {
    body()
    publishChecks name: name, conclusion: 'SUCCESS'
  } catch (e) {
    publishChecks name: name, conclusion: 'FAILURE', summary: e.toString()
    throw e
  }
}

def repoCheck(String name) {
  check(name) {
    container('tools') {
      sh """
        git config --global --add safe.directory "\$PWD"
        export BASE=\$(git rev-parse HEAD^1) HEAD=\$(git rev-parse HEAD^2 2>/dev/null || git rev-parse HEAD) BRANCH="\${CHANGE_BRANCH:-\$BRANCH_NAME}"
        export ALL_CHANGED="\$(git diff --name-only --diff-filter=ACMRT \$BASE \$HEAD | tr '\\n' ' ')"
        if [ ! -f .ci/checks/${name}.sh ]; then echo "no .ci/checks/${name}.sh on this commit"; exit 0; fi
        sh .ci/checks/${name}.sh
      """
    }
  }
}

pipeline {
  agent {
    kubernetes {
      yaml '''
spec:
  containers:
    - name: tools
      image: python:3.13-alpine
      command: [sleep]
      args: [infinity]
    - name: trufflehog
      image: trufflesecurity/trufflehog:3.92.4
      command: [sleep]
      args: [infinity]
'''
    }
  }
  stages {
    stage('setup') {
      steps {
        container('tools') {
          sh 'apk add -q --no-cache git && pip install -q --root-user-action=ignore yamllint shellcheck-py'
        }
      }
    }
    stage('checks') {
      parallel {
        stage('yaml-lint') { steps { script { repoCheck('yaml-lint') } } }
        stage('shellcheck') { steps { script { repoCheck('shellcheck') } } }
        stage('flaky') { steps { script { repoCheck('flaky') } } }
        stage('secret-scan') {
          steps {
            script {
              check('secret-scan') {
                container('trufflehog') {
                  sh '''
                    files="$(git diff --name-only --diff-filter=ACMRT HEAD^1 HEAD 2>/dev/null || true)"
                    if [ -z "$files" ]; then echo "no changed files"; exit 0; fi
                    trufflehog filesystem --fail --no-update $files
                  '''
                }
              }
            }
          }
        }
      }
    }
  }
}
