# Build Fedora AWS images with Image Builder in GitHub Actions

[![Deploy images](https://github.com/major/imagebuilder-fedora/actions/workflows/main.yml/badge.svg)](https://github.com/major/imagebuilder-fedora/actions/workflows/main.yml)

![doc/box.gif](doc/box.gif)

This repository contains a proof of concept for building Fedora images with
Image Builder and then deploying those images to AWS using GitHub Actions. It
takes less than 15 minutes to turn a basic image blueprint into a
ready-to-launch image on AWS.

Best of all, there is no infrastructure needed to build and deploy the images!
🎉

## What is Image Builder? 👷🏻‍♂️

[Image Builder] allows you build virtual machine images for almost any cloud or
virtualization system. It also deploys those images to AWS (Azure Google
Compute Engine coming soon). It consists of two main components:

* **osbuild:** low-level image building layer that takes image requirements and
  generates the appropriate image

* **osbuild-composer:** offers an easy to use API and queueing system for
  submitting image build requests and handling the deployment when the build is
  complete

Image specifications follow a [TOML-based blueprint reference] that allows you
to specify which packages to install, which services start at boot time, and
which configurations need to be changed.

[Image Builder]: https://www.osbuild.org/documentation/
[TOML-based blueprint reference]: https://weldr.io/lorax/composer-cli.html#blueprint-reference

## How does the repository work? ⚙

The [imagebuilder repository] builds containers with Image Builder pre-installed
for CentOS Stream 8, Fedora 34, and Fedora rawhide. The [GitHub actions
workflow] in this repository does the following:

1. Populates the AWS configuration
2. Builds the image inside the container
3. Uploads the image to AWS S3
4. Imports the image into EC2 and registers an AMI
5. Removes the image file from AWS S3

## How can I use it? 🤔

You can fork the repository into your own GitHub organization and add two
secrets to your GitHub Actions configuration.

1. Go to **Settings** &raquo; **Secrets**
2. Create `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets with your AWS credentials

To run a build, use the `workflow_dispatch` trigger in your GitHub workflows
listing or change any of the blueprints in the repository. You can add, remove,
or change which blueprints to build by adusting the `matrix.blueprint` list
inside the [GitHub actions workflow] file.

You should be able to see the AMIs and snapshots inside your AWS account:

![doc/aws-ami.png](doc/aws-ami.png)

![doc/aws-snapshot.png](doc/aws-snapshot.png)

## Something is broken! 😡

Feel free to open an issue, or better yet, make a pull request!

[imagebuilder repository]: https://github.com/major/imagebuilder/
[GitHub actions workflow]: blob/main/.github/workflows/build_containers.yml
