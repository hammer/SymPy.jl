module SymPy

using PyCall
@pyimport sympy

import Base.getindex
import Base: show, repl_show
import Base.convert, Base.complex
import Base: sin, cos, tan, sinh, cosh, tanh, asin, acos,
       atan, asinh, acosh, atanh, sec, csc, cot, asec,
       acsc, acot, sech, csch, coth, asech, acsch, acoth,
       sinc, cosc, cosd, cotd, cscd, secd, sind, tand,
       acosd, acotd, acscd, asecd, asind, atand, atan2,
       radians2degrees, degrees2radians, log, log2,
       log10, log1p, exponent, exp, exp2, expm1, cbrt, sqrt,
       square, erf, erfc, erfcx, erfi, dawson, ceil, floor,
       trunc, round, significand,
       abs, max, min, maximum, minimum,
       sign, dot,
       zero, one
import Base: transpose
import Base: factorial, gcd, lcm, isqrt
import Base: gamma, beta
import Base: length,  size
import Base: factor, expand, collect
import Base: !=, ==
import Base:  LinAlg.det, LinAlg.inv, LinAlg.conj,
              cross, eigvals, eigvecs, rref, trace, norm
import Base: promote_rule
import Base: has, match, replace, round
import Base: ^, .^
## poly.jl
import Base: div
import Base: trunc
import Base: isinf, isnan

export sympy, sympy_meth, object_meth, call_matrix_meth
export Sym, @sym_str, @syms, symbols
export pprint, latex, jprint
export SymFunction, SymMatrix,
       n,  subs,
       simplify, nsimplify, 
       expand, factor, trunc,
       collect, separate, 
       fraction,
       primitive, sqf, resultant, cancel,
       expand, together,
       solve,
       limit, diff, 
       series, integrate, 
       summation,
       I, oo,
       Ylm, assoc_legendre, chebyshevt, legendre, hermite,
       dsolve,
#       plot,
       poly,  nroots, real_roots
export members, doc, _sbtr


include("types.jl")
include("utils.jl")
include("mathops.jl")
include("math.jl")
include("core.jl")
include("simplify.jl")
include("functions.jl")
include("series.jl")
include("integrate.jl")
include("assumptions.jl")
include("poly.jl")
include("matrix.jl")
include("ntheory.jl")

## takes far too long
# include("plot.jl")


## create some methods

for meth in union(core_sympy_methods,
                  simplify_sympy_meths,
                  functions_sympy_methods,
                  series_sympy_meths,
                  integrals_sympy_methods,
                  summations_sympy_methods,
                  logic_sympy_methods,
                  polynomial_sympy_methods,
                  ntheory_sympy_methods
                  )

    meth_name = string(meth)
    @eval ($meth)(ex::Sym, args...; kwargs...) = sympy_meth(symbol($meth_name), ex, args...; kwargs...)
    eval(Expr(:export, meth))
end


for meth in union(core_object_methods,
                  integrals_instance_methods,
                  summations_instance_methods,
                  polynomial_instance_methods)

    meth_name = string(meth)
    @eval ($meth)(ex::Sym, args...; kwargs...) = object_meth(ex, symbol($meth_name), args...; kwargs...)
    eval(Expr(:export, meth))
end



for prop in union(core_object_properties,
                  summations_object_properties,
                  polynomial_predicates)
    
    prop_name = string(prop)
    @eval ($prop)(ex::Sym) = ex[symbol($prop_name)]
    eval(Expr(:export, prop))
end

## Conditional loads for graphing purposes
## user must load Gadfly or Winston first *before* loading SymPy

## add to plot if Gadfly is loaded
if :Gadfly in names(Main)
    using Gadfly
    Gadfly.plot(ex::Sym, args...; kwargs...) = plot(convert(Function, ex), args...; kwargs...)
    Gadfly.plot{T<:Sym}(exs::Vector{T}, args...; kwargs...) = plot(map(ex -> convert(Function, ex), exs), args...; kwargs...)
elseif :Winston in names(Main)
    using Winston
    Winston.plot(ex::Sym, args...; kwargs...) = plot(convert(Function, ex), args...; kwargs...)
    Winston.plot{T<:Sym}(exs::Vector{T}, args...; kwargs...) = plot(map(ex -> convert(Function, ex), exs), args...; kwargs...)
end



end
