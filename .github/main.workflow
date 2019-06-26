workflow "Deploy to Github Pages" {
  on = "push"
  resolves = [
    "Slack",
    "Build",
  ]
}

action "master branch only" {
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Install dependencies" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  needs = ["master branch only"]
  args = "ci"
}

action "Build" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  needs = ["Install dependencies"]
  args = "run build"
}

action "Deploy" {
  needs = "Build"
  uses = "peaceiris/actions-gh-pages@v1.0.1"
  env = {
    PUBLISH_DIR = "./www"
    PUBLISH_BRANCH = "gh-pages"
  }
  secrets = ["ACTIONS_DEPLOY_KEY"]
}

action "Slack" {
  uses = "Ilshidur/action-slack@6aeb2acb39f91da283faf4c76898a723a03b2264"
  needs = ["Deploy"]
  secrets = ["SLACK_WEBHOOK"]
  args = "A new commit has been pushed."
}
