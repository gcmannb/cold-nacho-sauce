### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 3294c0c6-1eb3-4245-b366-066565eb3732
using PlutoUI, HypertextLiteral, HTTP, JSON,Dates,TimeZones

# ╔═╡ a0b969d0-f5cf-4fda-b297-e9984972d015
md"""
# Cass Check Remittance

Enter payment UUID and find its resources across apps
"""

# ╔═╡ 3d413402-da50-407c-beb7-50b4494d9625
md"""Environment:"""

# ╔═╡ 988dbe39-208a-470e-bd13-db401e77c1f1
@bind env Select(["greek"])

# ╔═╡ 57e88d61-ee24-4f9e-8dec-1b7ab6f77897
payment_uuid = "f3602b7a-14c4-48a3-a65a-b7d938ef8b1b"

# ╔═╡ a03eadf1-ee0d-408e-b390-bb5ae45024b5
payment_uri = "gid://payments/Payment/$(payment_uuid)"

# ╔═╡ f18b4ad9-3089-4513-a890-3495c289b70c
@htl("""

<article class="link-box">
Payment <code>$(payment_uuid)</code>
<ul>
    <li>
        <a class="gcmannb-money" href="https://gcmannb-money-admin-$(env).gcmannb.example.com:10443/admin/payments?uuid=$(payment_uuid)">
			gcmannb-money Admin Panel
        </a>
    </li>
	<li>
        <a class="gcmannb-money-cs" href="https://gcmannb-money-admin-$(env).gcmannb.example.com:10443/clearing_system/admin/clearing_payments?payment_uri=$(payment_uri)">
			gcmannb-money (Clearing System) Admin Panel
        </a>
    </li>
</ul>
</article>

<style>

:root{
    --gcmannb-money:    #F2E527;
    --gcmannb-money-cs: #64732F;
    --gcmannb-monolith:   #CAD959;
    --gcmannb-gateway:  #B4BF5E;
	--gcmannb-sim:   #B400E0;

	text-decoration-skip-ink: none;
}
.link-box {
	padding: 2em;
	border: 2px #444 solid;
}
.link-box li {
	margin-bottom: 8px;
}
.gcmannb-money {
	text-decoration-color: var(--gcmannb-money);
	text-decoration-thickness: 4px;
}
.gcmannb-money-cs {
	text-decoration-color: var(--gcmannb-money-cs);
	text-decoration-thickness: 4px;
}
.gcmannb-gateway {
	text-decoration-color: var(--gcmannb-gateway);
	text-decoration-thickness: 4px;
}
.gcmannb-monolith {
	text-decoration-color: var(--gcmannb-monolith);
	text-decoration-thickness: 4px;
}
.gcmannb-sim {
	text-decoration-color: var(--gcmannb-sim);
	text-decoration-thickness: 4px;
}
</style>
""")

# ╔═╡ 791848ba-0e32-45c3-893e-5de96d6c2655
md"""
### Appendix
"""

# ╔═╡ 9f32f7ed-a5c9-40af-a4e3-a64b17ec8295
begin
  creds="XXX"
  me_creds = "XXX"
  md""
end

# ╔═╡ 80963c0f-3307-42b6-9fcc-7028a020d5a0
begin
	# Using gcmannb-money admin API, retrieve remittance entry
	resp = HTTP.get("https://$(creds)@gcmannb-money-admin-$(env).gcmannb.example.com:10443/clearing_system/admin/clearing_payments.json"; query=["payment_uri" => payment_uri])
	clearing_payments = JSON.parse(String(resp.body))
	remittance_entry_uri = clearing_payments[1]["clearing_entries"][2]["entry_uri"]

	# Using gcmannb-gateway admin API, retrieve remittance entry TDF, then its file name
	resp = HTTP.get("https://$(me_creds)@gcmannb-gateway-admin-$(env).gcmannb.example.com:26443/admin/remittance_entries.json?q%5Buri_contains%5D=$(HTTP.escapeuri(remittance_entry_uri))")
	remittance_entries = JSON.parse(String(resp.body))
	transaction_data_file_id = remittance_entries[1]["transaction_data_file_id"]

	resp = HTTP.get("https://$(me_creds)@gcmannb-gateway-admin-$(env).gcmannb.example.com:26443/admin/transaction_data_files/$(transaction_data_file_id).json")
	transaction_data_file = JSON.parse(String(resp.body))
	created_at = ZonedDateTime(transaction_data_file["created_at"], "yyyy-mm-ddTHH:MM:SS.s-z")
	tdf_ts = Dates.format(DateTime(created_at), "yyyymmddHHMMSS")  # Sad!
	transaction_data_file_name = "DOX2T0150$(tdf_ts).csv"
end
	

# ╔═╡ 3d4a17ef-307e-4759-9398-4b6fc624d7f7
@htl("""

<article class="link-box">
Remittance <code>$(remittance_entry_uri)</code>
<ul>
    <li>
        <a class="gcmannb-gateway" href="https://gcmannb-gateway-admin-$(env).gcmannb.example.com:26443/admin/remittance_entries?q%5Buri_contains%5D=$(HTTP.escapeuri(remittance_entry_uri))&commit=Filter&order=id_desc">
			gcmannb-gateway Admin Panel
        </a>
    </li>
</ul>
</article>
""")

# ╔═╡ ea4c7138-ea18-421c-bc06-5fe768a15e55
@htl("""

<article class="link-box">
Transaction Data File <code>$(transaction_data_file_name)</code>
<ul>
    <li>
        <a class="gcmannb-sim" href="https://gcmannb-sim-admin-$(env).gcmannb.example.com:12443/cass_info_systems/transaction_data_files?upload_file_name=$(transaction_data_file_name)">
			gcmannb-sim Admin Panel
        </a>
    </li>
</ul>
</article>
""")

# ╔═╡ ff4a4b55-58c6-427a-b23a-414b2d9156d0


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
TimeZones = "f269a46b-ccf7-5d73-abea-4c690281aa53"

[compat]
HTTP = "~1.0.5"
HypertextLiteral = "~0.9.4"
JSON = "~0.21.3"
PlutoUI = "~0.7.39"
TimeZones = "~1.8.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "9be8be1d8a6f44b96482c8af52238ea7987da3e3"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.45.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "bd11d3220f89382f3116ed34c92badaa567239c9"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.0.5"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "d19f9edd8c34760dca2de2b503f969d8700ed288"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "891d3b4e8f8415f53108b4918d0183e61e18015b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "29714d0a7a8083bba8427a4fbfb00a540c681ce7"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0044b23da09b5608b4ecacb4e5e6c6332f833a7e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "0a4d8838dc28b4bcfaa3a20efb8d63975ad6781d"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.8.0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─a0b969d0-f5cf-4fda-b297-e9984972d015
# ╟─3d413402-da50-407c-beb7-50b4494d9625
# ╟─988dbe39-208a-470e-bd13-db401e77c1f1
# ╟─57e88d61-ee24-4f9e-8dec-1b7ab6f77897
# ╟─a03eadf1-ee0d-408e-b390-bb5ae45024b5
# ╟─f18b4ad9-3089-4513-a890-3495c289b70c
# ╟─80963c0f-3307-42b6-9fcc-7028a020d5a0
# ╟─3d4a17ef-307e-4759-9398-4b6fc624d7f7
# ╟─ea4c7138-ea18-421c-bc06-5fe768a15e55
# ╟─791848ba-0e32-45c3-893e-5de96d6c2655
# ╠═3294c0c6-1eb3-4245-b366-066565eb3732
# ╠═9f32f7ed-a5c9-40af-a4e3-a64b17ec8295
# ╠═ff4a4b55-58c6-427a-b23a-414b2d9156d0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
