pipeline {
  agent any

  parameters {
    string(defaultValue: "test", description: "build type", name: "type")
  }

  stages {
    stage('prepare') {
      steps {
        echo "build type: ${params.type}"
        sh "env"
      }
    }

    stage('test') {
      when {
        expression {
          return params.type == "test"
        }
      }
      steps {
	sh 'export LANG=en_US.UTF-8'
	sh 'export LANGUAGE=en_US.UTF-8'
	sh 'export LC_ALL=en_US.UTF-8'
	sh 'bundle install --path vendor/bundler'
	sh 'bundle exec fastlane test'
      }
    }

  }
}
