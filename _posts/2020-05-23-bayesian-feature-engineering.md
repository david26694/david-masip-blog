---
toc: false
layout: post
categories: [feature-engineering, bayesian-statistics]
comments: true
title: A bayesian trick for feature engineering
---

### Problem formulation

You are building a model and, for the entity you want to infer, there is a history of binary events. For instance:

- Finance case: If you want to predict if someone will repay a loan, you have a history of the loans that they paid late or not.
- Marketing case: If you want to predict if someone will buy in an e-commerce, you have a history of times they clicked (or not clicked) in the ads that were sent via email.
- Logistics case: If you want to estimate the delay in the delivery of a package from a courier, you have a history of times that the courier arrived late to the package pick-up.

The naive method to deal with these event histories is to compute fractions regarding the past data. For the finance case, for instance, you'd compute the fraction of past loans what have been paid late. The higher this feature is, the more unlikely is the person to repay their loan. Everything looks right in here. 

However, when estimating these fractions, we have to be careful about the statiscal mass. If a client (A) has only recieved an email and not opened it, the fraction of opened emails will be 0. This is very different from another client (B) who's recieved 30 emails and not opened them. 

- Client A fraction of email clicking will be 0, but we have very low statistical mass, so we are underestimating its interest in buying.
- Client B fraction of email clicking will be 0, but we are pretty sure the client is not very interested in the ads we send.

In the loan case, if client C has got only 1 loan and paid it late, the fraction of late payments will be 1. If client D has got 10 loans and paid all of them late, they will also have this fraction to 1.

- Client C fraction of late payments will be 1, but we are not very sure if client C is a late payer.
- Client D fraction of late payments will be 1, and we are more sure that client D is a late payer.

This feature might be a good predictor but it seems to perform badly when new clients join: they might have this feature very high or very low just by chance, and this might hurt the model performance in this population.

### Bayesian statistics approach

A solution to this cold-start issue is to estimate fractions using a bayesian approach. Mathematically, the events can be modelled using a [Bernoulli distribution](https://en.wikipedia.org/wiki/Bernoulli_distribution) of probability $p$, where $p$ depends on each client. 

The simplest bayesian solution to estimating the parameter of a Bernoulli is the following (see [this post](http://www.sumsar.net/blog/2018/12/visualizing-the-beta-binomial/)):

- Assume $p$ has a [beta distribution](https://en.wikipedia.org/wiki/Beta_distribution).
- Update the beta parameters using the data from that client.
- Estimate $p$ as the mean of the posterior distribution.

We use the beta distribution because [it is the conjugate prior of the Bernoulli](https://en.wikipedia.org/wiki/Conjugate_prior#Table_of_conjugate_distributions). One issue that we have is providing the parameters $\alpha$ and $\beta$ of the prior distribution. 

If we don't want to assume much about $p$, we can use Jeffreys prior. In the beta distribution case, this is achieved by setting $\alpha = \beta = 1/2$. In this case, if the client has gone through $n$ events and $x$ of them have been successes ($n$ emails sent, $x$ of them opened), the bayesian fraction will be the following: 

$$\hat{p} = \frac{x + 0.5}{n + 1} $$

On the other hand, without the bayesian trick we would do $\hat{p} = \frac{x}{n}$.

If we know something about the distribution of $p$, we can assume more and choose $\alpha$ and $\beta$ such that the beta distribution represents our prior belief (I know this is a bit heuristic), [here's an app to explore the possible priors for the beta distribution](https://r.amherst.edu/apps/nhorton/Shiny-Bayes/).

### Extras

- This is not exclusive from estimating proportions, any feature that is an estimation of a parameter from a known distribution can be modelled in this way, but using another bayesian prior and update rule.
- A particular case of this is target encoding, which can be done using maximum likelihood or in a bayesian way.

