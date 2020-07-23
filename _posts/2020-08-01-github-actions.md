---
toc: false
layout: post
categories: [code]
comments: true
title: Github actions for CI/CD
subtitle: A beginner's guide
---

I recently started using github actions to test my python package [sktools](https://github.com/david26694/sktools/). It looks like a fairly easy tool to use, and I find it very powerful. 

The idea is to create workflows that automate actions for you. According to the [docs](https://docs.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow):

> Workflows are custom automated processes that you can set up in your repository to build, test, package, release, or deploy any project on GitHub.

Creating a workflow is as simple as creating a yml file in `.github/workflows`. The file I've created looks like this, and it installs the sktools package in several environments and runs its tests:

```yaml
# Action title
name: Unit Tests

# Controls when the action will run.
on:
  schedule:
    - cron: "0 0 * * *"

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        python-version: [3.6, 3.7]
        os: [macos-10.15, ubuntu-latest, windows-latest]

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
    # Runs a single command using the runners shell
    - uses: actions/checkout@v2
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v1
      with:
        python-version: ${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install sktools
        pip freeze
    - name: Test with pytest
      run: |
        make test
```

Let's look at what each step does. 


The `name` key is provided so it'll be easily identified in the [actions tab](https://github.com/david26694/sktools/actions). The `on` key controls when the workflow will be run. In this case, it is scheduled via a cron that runs the action on a daily basis, at midnight.

``` yaml
# Workflow title
name: Unit Tests

# Controls when the action will run.
on:
  schedule:
    - cron: "0 0 * * *"
```

Alternative `on` options are:

``` yaml
on:
  push:
    branches:
    - master
  pull_request:
    branches:
    - master
```

Which would run the workflow when master branch is updated and on pull requests. Of course `on` can handle all of them at the same time.

After that, you can specify several jobs for the workflow to run. In our case, we've specified a single job called `build`. We've also specified on which environments do we need to run it on. The idea is that the instructions that we'll specify afterwards will run in mac, ubuntu and windows and both in python 3.6 and 3.7 for each of the OS. And this is without even having python 3.6 in my computer, and only one OS. This way I can ensure that my library works not only in my computer.

``` yaml

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        python-version: [3.6, 3.7]
        os: [macos-10.15, ubuntu-latest, windows-latest]
```

In the following lines we define the steps that each execution of the workflow will carry. Each step is defined by a yaml key, the first one being the checkout. The checkout gets the latest commit of your repo. The second action, with name `Set up Python 3.x`, will create a python environment. 

Both these steps are open source ([setup python](https://github.com/actions/setup-python), [checkout](https://github.com/actions/checkout)), and you can also build your own custom steps. 

``` yaml

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
    # Runs a single command using the runners shell
    - uses: actions/checkout@v2
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v1
      with:
        python-version: ${{ matrix.python-version }}
```

The last steps are the most specific to our job. The "Install dependencies" job installs sktools and the last step runs the tests in sktools.

``` yaml

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install sktools
        pip freeze
    - name: Test with pytest
      run: |
        make test
```

The `make test` is specific to our project as we run the tests from a Makefile. However, as in the Makefile we have the lines

```
test: 
	python setup.py test
```

changing the `make test` by `python setup.py test` won't make any difference. By looking in the workflow run in the actions tab on github, we can see in its logs:

```
test_basic_featurizer (tests.test_sktools.TestGroupQuantileFeaturizer) ... ok
test_missing (tests.test_sktools.TestGroupQuantileFeaturizer) ... ok
test_new_input (tests.test_sktools.TestGroupQuantileFeaturizer) ... ok
test_select_items (tests.test_sktools.TestItemSelector) ... ok
test_zero_matrix (tests.test_sktools.TestMatrixDenser) ... ok
test_basic_featurizer (tests.test_sktools.TestMeanFeaturizer) ... ok
test_missing (tests.test_sktools.TestMeanFeaturizer) ... ok
test_new_input (tests.test_sktools.TestMeanFeaturizer) ... ok
test_float_works (tests.test_sktools.TestTypeSelector) ... ok
test_integer_works (tests.test_sktools.TestTypeSelector) ... ok
test_object_works (tests.test_sktools.TestTypeSelector) ... ok
test_all_missing (tests.test_encoders.TestNestedTargetEncoder) ... ok
test_missing_na (tests.test_encoders.TestNestedTargetEncoder) ... ok
test_no_parent (tests.test_encoders.TestNestedTargetEncoder) ... ok
test_numpy_array (tests.test_encoders.TestNestedTargetEncoder) ... ok
test_parent_prior (tests.test_encoders.TestNestedTargetEncoder) ... ok
test_unknown_missing_imputation (tests.test_encoders.TestNestedTargetEncoder) ... ok
test_max_works (tests.test_encoders.TestQuantileEncoder) ... ok
test_median_works (tests.test_encoders.TestQuantileEncoder) ... ok
test_new_category (tests.test_encoders.TestQuantileEncoder) ... ok
test_several_quantiles (tests.test_encoders.TestSummaryEncoder) ... ok
test_period_mapping (tests.test_preprocessing.TestCyclicFeaturizer)
Expect same output by specifying period mapping ... ok
test_trigonometry (tests.test_preprocessing.TestCyclicFeaturizer)
Expect cosines and sines to work ... ok
test_with_intercept (tests.test_linear_model.TestQuantileRegression) ... ok
test_without_intercept (tests.test_linear_model.TestQuantileRegression) ... ok
test_1_tree (tests.test_ensemble.TestMedianForest) ... ok
test_2_trees (tests.test_ensemble.TestMedianForest) ... ok
test_many_trees (tests.test_ensemble.TestMedianForest) ... ok
test_cross_val_integration (tests.test_model_selection.TestBootstrapFold)
Check cv is compatible with cross_val_score ... ok
test_grid_integration (tests.test_model_selection.TestBootstrapFold)
Check that cv is compatible with GridSearchCV ... ok
test_n_splits (tests.test_model_selection.TestBootstrapFold)
Check that get_n_splits returns the number of bootstraps ... ok
test_size_fraction_works (tests.test_model_selection.TestBootstrapFold)
Check that size_fraction works as expected ... ok

----------------------------------------------------------------------
Ran 36 tests in 2.041s

OK
```

The tests are passing, yay!