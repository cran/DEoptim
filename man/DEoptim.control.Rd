\name{DEoptim.control}
\alias{DEoptim.control}
\title{Control various aspects of the DEoptim implementation}
\description{
  Allow the user to set some characteristics of the 
  Differential Evolution optimization algorithm implemented
  in \code{DEoptim}.
}
\usage{
DEoptim.control(VTR = -Inf, strategy = 2, bs = FALSE, NP = NA,
  itermax = 200, CR = 0.5, F = 0.8, trace = TRUE, initialpop = NULL,
  storepopfrom = itermax + 1, storepopfreq = 1, p = 0.2, c = 0, reltol,
  steptol, parallelType = c("none", "auto", "parallel", "foreach"),
  cluster = NULL, packages = c(), parVar = c(),
  foreachArgs = list(), parallelArgs = NULL)
}
\arguments{
   \item{VTR}{the value to be reached. The optimization process
      will stop if either the maximum number of iterations \code{itermax}
      is reached or the best parameter vector \code{bestmem} has found a value
      \code{fn(bestmem) <= VTR}. Default to \code{-Inf}.}
  \item{strategy}{defines the Differential Evolution
    strategy used in the optimization procedure:\cr
     \code{1}: DE / rand / 1 / bin (classical strategy)\cr
     \code{2}: DE / local-to-best / 1 / bin (default)\cr
     \code{3}: DE / best / 1 / bin with jitter\cr
     \code{4}: DE / rand / 1 / bin with per-vector-dither\cr
     \code{5}: DE / rand / 1 / bin with per-generation-dither\cr
     \code{6}: DE / current-to-p-best / 1\cr
     any value not above: variation to DE / rand / 1 / bin: either-or-algorithm.  Default
     strategy is currently \code{2}. See *Details*.
    }
    \item{bs}{if \code{FALSE} then every mutant will be tested against a
      member in the previous generation, and the best value will proceed
      into the next generation (this is standard trial vs. target
      selection). If \code{TRUE} then the old generation and \code{NP}
      mutants will be sorted by their associated objective function
      values, and the best \code{NP} vectors will proceed into the next
      generation (best of parent and child selection). Default is
    \code{FALSE}.}
    \item{NP}{number of population members. Defaults to \code{NA}; if
      the user does not change the value of \code{NP} from \code{NA} or
      specifies a value less than 4 it
      is reset when \code{DEoptim} is called as \code{10*length(lower)}. For
      many problems it is best to set
      \code{NP} to be at least 10 times the length
      of the parameter vector.  }
    \item{itermax}{the maximum iteration (population generation) allowed.
      Default is \code{200}.}
    \item{CR}{crossover probability from interval [0,1]. Default
      to \code{0.5}.}
    \item{F}{differential weighting factor from interval [0,2]. Default
      to \code{0.8}.}
    \item{trace}{Positive integer or logical value indicating whether 
  printing of progress occurs at each iteration. The default value is
  \code{TRUE}.  If a positive integer is specified, printing occurs every
  \code{trace} iterations.  }
    \item{initialpop}{an initial population used as a starting
      population in the optimization procedure. May be useful to speed up
      the convergence. Default to \code{NULL}.  If given, each member of
    the initial population should be given as a row of a numeric matrix, so that
   \code{initialpop} is a matrix with \code{NP} rows and a number of
   columns equal to the length of the parameter vector to be optimized. }
    \item{storepopfrom}{from which generation should the following
      intermediate populations be stored in memory. Default to
      \code{itermax + 1}, i.e., no intermediate population is stored.}
    \item{storepopfreq}{the frequency with which populations are stored.
      Default to \code{1}, i.e., every intermediate population
      is stored.}
 \item{p}{when \code{strategy = 6}, the top (100 * p)\% best 
   solutions are used in the mutation. \code{p} must be defined in (0,1].}
 \item{c}{\code{c} controls the speed of the
   crossover adaptation. Higher values of \code{c} give more weight to the
   current successful mutations. \code{c} must be defined in (0,1].}
 \item{reltol}{relative convergence tolerance.  The algorithm stops if
   it is unable to reduce the value by a factor of \code{reltol * (abs(val) +
   reltol)} after \code{steptol} steps. Defaults to
   \code{sqrt(.Machine$double.eps)}, typically about \code{1e-8}.}
 \item{steptol}{see \code{reltol}. Defaults to \code{itermax}.}
 \item{parallelType}{Defines the type of parallelization to employ, if
   any.
    \code{none}: The default, this uses \code{DEoptim} on only one core.
     \code{auto}: will attempt to auto-detect \code{foreach}, or \code{parallel}.
     \code{parallel}: This uses all available cores, via the \pkg{parallel}
     package, to run \code{DEoptim}.  
     \code{foreach}: This uses the \pkg{foreach} package for parallelism; see
     the \code{sandbox} directory in the source code for examples. 
  }
   \item{cluster}{Existing \pkg{parallel} cluster object. If provided, overrides
+  specified \code{parallelType}. Using \code{cluster} allows fine-grained control
+  over the number of used cores and exported data.}
  \item{packages}{Used if  \code{parallelType='parallel'}; a list of
    package names (as strings) that need to be loaded for use by the objective
  function. }
\item{parVar}{Used if  \code{parallelType='parallel'};  a list of variable names
  (as strings) that need to exist in the environment for use by the
  objective function or are used as arguments by the objective
  function. }  
  \item{foreachArgs}{A list of named arguments for the \code{foreach}
    function from the
    package \pkg{foreach}.  The arguments \code{i}, \code{.combine} and
    \code{.export} are not possible to set here; they are set
    internally. }
 \item{parallelArgs}{A list of named arguments for the parallel engine.
  For package \pkg{foreach}, the argument \code{i} is not possible to
  set here; it is set internally. }
 }
\value{
  The default value of \code{control} is the return value of 
  \code{DEoptim.control()}, which is  a list (and a member of the
  \code{S3} class  
  \code{DEoptim.control}) with the above elements.
}
\details{
  This defines the Differential Evolution 
  strategy used in the optimization procedure, described below in the 
  terms used by Price et al. (2006); see also Mullen et al. (2009) for details. 
  
  \itemize{
    \item \code{strategy = 1}: DE / rand / 1 / bin. \cr 
    This strategy is the classical approach for DE, and is described in \code{\link{DEoptim}}. 
  
    \item \code{strategy = 2}: DE / local-to-best / 1 / bin. \cr
    In place of the classical DE mutation the expression
    \deqn{
      v_{i,g} = old_{i,g} + (best_{g} - old_{i,g}) + x_{r0,g} + F \cdot (x_{r1,g} - x_{r2,g})
    }{
      v_i,g = old_i,g + (best_g - old_i,g) + x_r0,g + F * (x_r1,g - x_r2,g)
    } 
    is used, where \eqn{old_{i,g}}{old_i,g} and \eqn{best_{g}}{best_g} are the 
    \eqn{i}-th member and best member, respectively, of the previous population.
    This strategy is currently used by default.  
  
    \item \code{strategy = 3}: DE / best / 1 / bin with jitter.\cr
    In place of the classical DE mutation the expression
    \deqn{
       v_{i,g} = best_{g} + jitter + F \cdot (x_{r1,g} - x_{r2,g}) 
     }{
       v_i,g = best_g + jitter + F * (x_r1,g - x_r2,g) 
     }
     is used, where \eqn{jitter} is defined as 0.0001 * \code{rand} + F.
  
    \item \code{strategy = 4}: DE / rand / 1 / bin with per vector dither.\cr
     In place of the classical DE mutation the expression
    \deqn{
       v_{i,g} = x_{r0,g} + dither \cdot (x_{r1,g} - x_{r2,g})
     }{
       v_i,g = x_r0,g + dither * (x_r1,g - x_r2,g)
     }
     is used, where \eqn{dither} is calculated as \eqn{F + \code{rand} * (1 - F)}.
      
     \item \code{strategy = 5}: DE / rand / 1 / bin with per generation dither.\cr
     The strategy described for \code{4} is used, but \eqn{dither}
     is only determined once per-generation. 
     
     \item \code{strategy = 6}: DE / current-to-p-best / 1.\cr
     The top \eqn{(100*p)} percent best solutions are used in the mutation,
     where \eqn{p} is defined in \eqn{(0,1]}.
     
     \item any value not above: variation to DE / rand / 1 / bin: either-or algorithm.\cr
     In the case that \code{rand} < 0.5, the classical strategy \code{strategy = 1} is used. 
     Otherwise, the expression
     \deqn{
       v_{i,g} = x_{r0,g} + 0.5 \cdot (F + 1) \cdot (x_{r1,g} + x_{r2,g} -  2 \cdot x_{r0,g})
     }{
       v_i,g = x_r0,g + 0.5 * (F + 1) * (x_r1,g + x_r2,g -  2 * x_r0,g)
     }
     is used. 
  }
  
  Several conditions can cause the optimization process to stop:
  \itemize{
    \item{if the best parameter vector (\code{bestmem}) produces a value
      less than or equal to \code{VTR} (i.e. \code{fn(bestmem) <= VTR}), or}
    \item{if the maximum number of iterations is reached (\code{itermax}), or}
    \item{if a number (\code{steptol}) of consecutive iterations are unable
      to reduce the best function value by a certain amount (\code{reltol *
      (abs(val) + reltol)}). \code{100*reltol} is approximately the percent
      change of the objective value required to consider the parameter set
      an improvement over the current best member.}
  }

  Zhang and Sanderson (2009) define several extensions to the DE algorithm, 
  including strategy 6, DE/current-to-p-best/1. They also define a self-adaptive 
  mechanism for the other control parameters.  This self-adaptation will speed 
  convergence on many problems, and is defined by the control parameter \code{c}.
  If \code{c} is non-zero, crossover and mutation will be adapted by the algorithm.  
  Values in the range of \code{c=.05} to \code{c=.5} appear to work best for most 
  problems, though the adaptive algorithm is robust to a wide range of \code{c}.
    
}
\note{
  Further details and examples of the \R package \pkg{DEoptim} can be found
  in Mullen et al. (2011) and Ardia et al. (2011a, 2011b) or look at the 
  package's vignette by typing \code{vignette("DEoptim")}. Also, an illustration of
  the package usage for a high-dimensional non-linear portfolio optimization problem 
  is available by typing \code{vignette("DEoptimPortfolioOptimization")}. 

  Please cite the package in publications. Use \code{citation("DEoptim")}.
}
\seealso{
  \code{\link{DEoptim}} and \code{\link{DEoptim-methods}}.
}
\references{
  Ardia, D., Boudt, K., Carl, P., Mullen, K.M., Peterson, B.G. (2011)
  Differential Evolution with \pkg{DEoptim}. An Application to Non-Convex Portfolio Optimization. 
  \emph{R Journal}, 3(1), 27-34. 
  \doi{10.32614/RJ-2011-005}

  Ardia, D., Ospina Arango, J.D., Giraldo Gomez, N.D. (2011)
  Jump-Diffusion Calibration using Differential Evolution. 
  \emph{Wilmott Magazine}, 55 (September), 76-79.
  \doi{10.1002/wilm.10034}

  Mullen, K.M, Ardia, D., Gil, D., Windover, D., Cline,J. (2011). 
  \pkg{DEoptim:} An R Package for Global Optimization by Differential Evolution. 
  \emph{Journal of Statistical Software}, 40(6), 1-26.
  \doi{10.18637/jss.v040.i06}
  
  Price, K.V., Storn, R.M., Lampinen J.A. (2006)
  \emph{Differential Evolution - A Practical Approach to Global Optimization}.
  Berlin Heidelberg: Springer-Verlag. ISBN 3540209506.
  
  Zhang, J. and Sanderson, A. (2009) 
  \emph{Adaptive Differential Evolution}
  Springer-Verlag. ISBN 978-3-642-01526-7
}
\author{
  David Ardia, Katharine Mullen \email{mullenkate@gmail.com}, 
  Brian Peterson and Joshua Ulrich.
}
\examples{
## set the population size to 20
DEoptim.control(NP = 20)

## set the population size, the number of iterations and don't
## display the iterations during optimization
DEoptim.control(NP = 20, itermax = 100, trace = FALSE)
   
}
\keyword{nonlinear}
\keyword{optimize}