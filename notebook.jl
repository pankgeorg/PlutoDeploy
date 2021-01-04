### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 111c96ce-43d8-11eb-2a3c-c93c2242a22d
begin
	import Pkg
	Pkg.activate(".")
	using ClimateMARGO
	using ClimateMARGO.Models
	using ClimateMARGO.Optimization
	using ClimateMARGO.Diagnostics
	using Plots
	using PlutoUI
end

# ╔═╡ bf98995e-43d9-11eb-2e0b-0bc7ff69ab9f
md"""
# ClimateMARGO

This minimal ClimateMARGO notebook is only meant as a tech demo, see the ClimateMARGO repository for more info about the model.
"""

# ╔═╡ 243a70e6-43d8-11eb-0ccb-8fa15dbb9f8b
model_parameters = deepcopy(ClimateMARGO.IO.included_configurations["default"])

# ╔═╡ 432f7262-43d8-11eb-0f85-7b631b297520
md"#### Maximum temperature: 
0.0 °C $(@bind T_max Slider(0.0:0.01:3.0, default=2)) 3.0 °C"

# ╔═╡ 3c3f3e54-43d8-11eb-018d-4f78697cabe0
begin
	model = ClimateModel(model_parameters)
	
	# run the optimization and save the progress report
	model_optimizer = optimize_controls!(model; print_raw_status=false, temp_goal=T_max)
	
	ClimateMARGO.Optimization.JuMP.termination_status(model_optimizer) |> string
end

# ╔═╡ ee5fbc50-43d8-11eb-149f-7d6fec48c0f7
time = let
	d = model_parameters.domain
	d.initial_year:d.dt:d.final_year
end

# ╔═╡ 6d88cb70-43d9-11eb-348b-edc8f1df42a5
let
	p = plot(dpi=300)
	plot!(p, time, model.controls.mitigate, label="Mitigate")
	plot!(p, time, model.controls.remove, label="CO2 Removal")
	plot!(p, time, model.controls.geoeng, label="Geo-engineering")
	plot!(p, time, model.controls.adapt, label="Adapt")
end

# ╔═╡ d72a8d8a-43d8-11eb-0990-ed2af0b20026
temperatures = Diagnostics.T(model; M=true, G=true, R=true)

# ╔═╡ 9b3dd7e0-43d9-11eb-2fb3-efa8f23f305d
let
	p = plot(dpi=300, ylim=(0, 3), ylabel="Global warming")
	plot!(p, time, temperatures)
	plot!(p, time, [T_max for _ in time], label="Goal")
end

# ╔═╡ Cell order:
# ╟─bf98995e-43d9-11eb-2e0b-0bc7ff69ab9f
# ╠═111c96ce-43d8-11eb-2a3c-c93c2242a22d
# ╠═243a70e6-43d8-11eb-0ccb-8fa15dbb9f8b
# ╟─432f7262-43d8-11eb-0f85-7b631b297520
# ╟─9b3dd7e0-43d9-11eb-2fb3-efa8f23f305d
# ╟─6d88cb70-43d9-11eb-348b-edc8f1df42a5
# ╠═3c3f3e54-43d8-11eb-018d-4f78697cabe0
# ╠═ee5fbc50-43d8-11eb-149f-7d6fec48c0f7
# ╠═d72a8d8a-43d8-11eb-0990-ed2af0b20026