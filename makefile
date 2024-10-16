UNITY_ASSEMBLY_PATH?="/Applications/Unity/Hub/Editor/2022.3.47f1/Unity.app/Contents/Managed/"
PACKAGE_PREFIX?="KageKirin."

format: $(shell fd --max-depth=2 csproj$)
	dos2unix -q -r $^

restore: prepare
	cd com.unity.mathematics; UNITY_ASSEMBLY_PATH=$(UNITY_ASSEMBLY_PATH) PACKAGE_PREFIX=$(PACKAGE_PREFIX) dotnet build -tl

build: restore
	cd com.unity.mathematics; UNITY_ASSEMBLY_PATH=$(UNITY_ASSEMBLY_PATH) PACKAGE_PREFIX=$(PACKAGE_PREFIX) dotnet build -tl

pack: build
	cd com.unity.mathematics; UNITY_ASSEMBLY_PATH=$(UNITY_ASSEMBLY_PATH) PACKAGE_PREFIX=$(PACKAGE_PREFIX) dotnet pack -tl
	fd nupkg$$ -- com.unity.mathematics/.artifacts

prepare:	\
	com.unity.mathematics/README.md \
	com.unity.mathematics/Directory.Build.props \
	com.unity.mathematics/Unity.Mathematics.sln \
	com.unity.mathematics/Unity.Mathematics/Unity.Mathematics.csproj \
	com.unity.mathematics/Unity.Mathematics/Unity.Mathematics.NoDeps.csproj \
	com.unity.mathematics/Unity.Mathematics.Editor/Unity.Mathematics.Editor.csproj

com.unity.mathematics:
	git clone https://github.com/needle-mirror/com.unity.mathematics.git || \
		(git -C com.unity.mathematics reset --hard origin/master && \
		git -C com.unity.mathematics pull)

com.unity.mathematics/README.md:	com.unity.mathematics
	cp README.md com.unity.mathematics/README.md

com.unity.mathematics/Unity.Mathematics.sln:	com.unity.mathematics
	cp Unity.Mathematics.sln com.unity.mathematics/Unity.Mathematics.sln

com.unity.mathematics/Directory.Build.props:	com.unity.mathematics
	cp Directory.Build.props com.unity.mathematics/Directory.Build.props

com.unity.mathematics/Unity.Mathematics/Unity.Mathematics.csproj:	com.unity.mathematics
	cp Unity.Mathematics/Unity.Mathematics.csproj com.unity.mathematics/Unity.Mathematics/Unity.Mathematics.csproj

com.unity.mathematics/Unity.Mathematics/Unity.Mathematics.NoDeps.csproj:	com.unity.mathematics
	cp Unity.Mathematics/Unity.Mathematics.NoDeps.csproj com.unity.mathematics/Unity.Mathematics/Unity.Mathematics.NoDeps.csproj

com.unity.mathematics/Unity.Mathematics.Editor/Unity.Mathematics.Editor.csproj:	com.unity.mathematics
	cp Unity.Mathematics.Editor/Unity.Mathematics.Editor.csproj com.unity.mathematics/Unity.Mathematics.Editor/Unity.Mathematics.Editor.csproj
