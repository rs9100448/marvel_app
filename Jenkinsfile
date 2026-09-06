// Jenkinsfile — MarvelApp CI
//
// This mirrors .github/workflows/ci.yml stage-for-stage. Both call the SAME
// Fastlane lanes (fastlane/Fastfile), so GitHub Actions and Jenkins produce
// identical results — the only real difference is the runner:
//
//   GitHub Actions -> Mac provided & managed by GitHub (zero infra)
//   Jenkins        -> Mac that YOU provide and maintain (the agent below)
//
// PREREQUISITES this file assumes Jenkins already has (GitHub gives these for
// free; with Jenkins you set them up once on the agent):
//   * A macOS build agent labelled 'macos' with Xcode installed
//   * A non-system Ruby 3.x on that agent (e.g. via rbenv) + `bundle`
//   * (Later, for signing) credentials added to the Jenkins Credentials store

pipeline {
  // GitHub Actions equivalent: `runs-on: macos-15`
  agent { label 'macos' }

  options {
    timestamps()
    ansiColor('xterm')
    // GitHub Actions equivalent: concurrency.cancel-in-progress
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  // GitHub Actions equivalent: the top-level `env:` block.
  environment {
    LANG   = 'en_US.UTF-8'
    LC_ALL = 'en_US.UTF-8'
    // Jenkins (a launchd service) doesn't load your shell profile, so put the
    // toolchain on PATH explicitly: rbenv shims (Ruby 3.3.6 + bundle), Homebrew,
    // and the system dirs where xcodebuild/xcrun live.
    PATH = "$HOME/.rbenv/shims:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  }

  triggers {
    // For a Multibranch Pipeline job, branch/PR triggers come from Jenkins
    // itself. This is a safety-net poll; prefer a GitHub webhook in real use.
    pollSCM('H/5 * * * *')
  }

  stages {
    // === GitHub Actions: actions/checkout@v4 ===
    stage('Checkout') {
      steps { checkout scm }
    }

    // === GitHub Actions: ruby/setup-ruby (+ "Show toolchain") ===
    stage('Setup') {
      steps {
        sh '''
          xcodebuild -version
          ruby -v
          bundle install
        '''
      }
    }

    // === GitHub Actions: "Build for simulator (unsigned)" ===
    stage('Build') {
      steps { sh 'bundle exec fastlane build_ci' }
    }

    // === GitHub Actions: "Run unit tests" ===
    stage('Unit Tests') {
      steps { sh 'bundle exec fastlane test' }
    }

    // === GitHub Actions: the separate "Archive (unsigned)" job,
    //     gated with `if: github.ref == 'refs/heads/main' || workflow_dispatch` ===
    stage('Archive (unsigned)') {
      when { branch 'main' }
      steps { sh 'bundle exec fastlane archive' }
    }

    // ------------------------------------------------------------------
    // TODO: add a 'Deploy' stage here once signing + App Store Connect exist,
    // mirroring the GitHub Actions deploy job:
    //
    // stage('TestFlight') {
    //   when { branch 'main' }
    //   steps {
    //     withCredentials([
    //       string(credentialsId: 'asc-key-id',      variable: 'ASC_KEY_ID'),
    //       string(credentialsId: 'asc-issuer-id',   variable: 'ASC_ISSUER_ID'),
    //       string(credentialsId: 'asc-key-content', variable: 'ASC_KEY_CONTENT'),
    //       string(credentialsId: 'match-password',  variable: 'MATCH_PASSWORD')
    //     ]) {
    //       sh 'bundle exec fastlane beta'
    //     }
    //   }
    // }
    // ------------------------------------------------------------------
  }

  post {
    // === GitHub Actions: "Upload test results" / "Upload .xcarchive" ===
    always {
      junit allowEmptyResults: true, testResults: 'fastlane/test_output/**/*.junit'
      archiveArtifacts artifacts: 'fastlane/test_output/**', allowEmptyArchive: true
      archiveArtifacts artifacts: 'build/MarvelApp.xcarchive/**', allowEmptyArchive: true
    }
    failure { echo 'Build failed — check the stage logs above.' }
    success { echo 'All stages passed.' }
  }
}
