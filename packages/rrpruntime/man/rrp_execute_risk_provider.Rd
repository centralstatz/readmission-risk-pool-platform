\name{rrp_execute_risk_provider}
\alias{rrp_execute_risk_provider}
\title{Execute One Compatible Risk Provider}
\usage{
rrp_execute_risk_provider(episode_state, provider, expected_context)
}
\arguments{
\item{episode_state}{One eligible \code{rrp_episode_state}.}
\item{provider}{One closed semantic provider declaration and trusted callable.}
\item{expected_context}{The exact software and runtime contract context.}
}
\value{One detached object with class \code{c("rrp_risk_estimate", "list")}.}
\description{
Revalidates immutable episode state and semantic provider compatibility,
constructs one provider-neutral request, invokes the provider exactly once,
and returns one accepted finite probability estimate. Expected failures use
bounded \code{rrp_runtime_error} conditions.
}
