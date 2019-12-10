# Contributing

We love contributions from everyone. When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. 

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a 
   build.
2. Update the README.md with details of changes to the interface, this includes new environment 
   variables, exposed ports, useful file locations and container parameters.
3. Increase the version numbers in any examples files and the README.md to the new version that this
   Pull Request would represent. The versioning scheme we use is [SemVer](http://semver.org/).
4. You may merge the Pull Request in once you have the sign-off of two other developers, or if you 
   do not have permission to do that, you may request the second reviewer to merge it for you.

We expect everyone to follow the code of conduct anywhere in this project's codebases, issue trackers, chatrooms, and mailing lists.

## Contributing Code

$(INSTALL_DEPENDENCIES)

Fork the repo.

Make sure the tests pass:

    $(TEST_RUNNER)

Make your change, with new passing tests. Follow the [style guide][style].

  [style]: https://github.com/thoughtbot/guides/tree/master/style

Mention how your changes affect the project to other developers and users in the
`NEWS.md` file.

Push to your fork. Write a [good commit message][commit]. Submit a pull request.

  [commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

Others will give constructive feedback.
This is a time for discussion and improvements, and making the necessary changes will be required before we can merge the contribution.
