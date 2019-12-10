# Contributing

We love contributions from everyone. When contributing to the **MetaGWASToolKit** repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change. 

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a build.
2. Update the README.md with details of changes to the interface, this includes new environment variables, exposed ports, useful file locations and container parameters.
3. Increase the version numbers in any examples files and the `README.md` to the new version that this _Pull Request_ would represent. Each version and release name will be based on places or characters of importance in one of the [Dutch provinces](https://en.wikipedia.org/wiki/Provinces_of_the_Netherlands){target="_blank"}.
4. You may merge the _Pull Request_ in once you have the sign-off of two other developers, or if you do not have permission to do that, you may request the second reviewer to merge it for you.

We expect everyone to follow the code of conduct anywhere in this project's codebases, issue trackers, chatrooms, and mailing lists.

## Contributing Code

    $(INSTALL_DEPENDENCIES)

Fork the repo.

Make sure the tests pass:

    $(TEST_RUNNER)

Make your change, with new passing tests. Follow the [style guide][style] based on the `thoughbot` repository.

  [style]: https://github.com/thoughtbot/guides/tree/master/style

Mention how your changes affect the project to other developers and users in the `NEWS.md` file.

Push to your fork. Write a [good commit message][commit]. Submit a _Pull Request_.

  [commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html

Others will give constructive feedback.
This is a time for discussion and improvements, and making the necessary changes will be required before we can merge the contribution.
