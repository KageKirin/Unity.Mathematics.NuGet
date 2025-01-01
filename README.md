# Unity.Mathematics for NuGet

This repo consists of build scripts and .NET projects
that work on the [official Unity.Mathematics repo](https://github.com/Unity-Technologies/Unity.Mathematics),
or rather its [unofficial mirror](https://github.com/needle-mirror/com.unity.mathematics),
to create NuGet packages that are deployed to the GitHub NuGet repository.

The intention is to make Unity.Mathematics usable by regular .NET classlibs (and thus NuGet packages)
that could also be distributed as Unity packages containing precompiled assemblies.

## tl;dr or _I just want to fetch the correct dependency_

### Regular C# project (classlib or app)

```xml
<ItemGroup>
  <PackageReference Include="UnityMathematics.NoDeps" Version="1.3.2" PrivateAssets="All"/>
</ItemGroup>
```

```bash
dotnet add package UnityMathematics.NoDeps --version 1.3.2
```

### Classlib distributed as Unity package and consumed by Unity only

```xml
<ItemGroup>
  <PackageReference Include="UnityMathematics" Version="1.3.2" PrivateAssets="All"/>
</ItemGroup>
```

```bash
dotnet add package UnityMathematics --version 1.3.2
```

## Projects and NuGet packages

### UnityMathematics

This project and NuGet package is the verbatim Unity.Mathematics package
which has a dependency on the UnityEngine.dll.

As such, projects referencing this package _might_ (untested atm) also require
to provide a PathHint to the aforementioned assembly.
(See below for more information about this process).

### UnityMathematics.Editor

This project and NuGet package is the verbatim Unity.Mathematics.Editor package
which has a dependency on both the UnityEngine.dll and the UnityEditor.dll.

As such, it is not recommended to reference this package by other classlibs.

In case classlibs still want to reference this package, they will also require
to provide PathHints to the aforementioned assemblies.
(See below for more information about this process).

### UnityMathematics.NoDeps

This project and NuGet package is a slightly modified Unity.Mathematics package
that **does not** have any dependency on UnityEngine.dll.

As such, it is the preferred dependency for regular .NET classlib and program projects.

In detail: there are 2 files causing the dependency on UnityEngine:

- `math_unity_conversion.cs` implementing straight cast operators between UnityEngine types and Unity.Mathematics ones,
- and `PropertyAttributes.cs` defining 2 attributes inheriting from `UnityEngine.PropertyAttribute`
  (Note that those attributes are not further reference in Unity.Mathematics itself, but by Unity.Mathematics.Editor).

Those 2 files are excluded from compilation through specific project settings.

### Absent projects

Unity.Mathematics.Tests does not have an equivalent project as it is not required for regular compilation.

## Referencing Unity assemblies through PathHint

```xml
  <ItemGroup Label="Unity">
    <Reference Include="UnityEngine">
      <HintPath>$(UNITY_ASSEMBLY_PATH)\UnityEngine.dll</HintPath>
    </Reference>
    <Reference Include="UnityEditor">
      <HintPath>$(UNITY_ASSEMBLY_PATH)\UnityEditor.dll</HintPath>
    </Reference>
  </ItemGroup>
```

with the environment variable `UNITY_ASSEMBLY_PATH` pointing to the directory containing the Unity Editor executable.

- e.g. on macOS: `C:\Program Files\Unity\Hub\Editor\2022.3.47f1\Editor\Data\Managed`.
- e.g. on Windows: `/Applications/Unity/Hub/Editor/2022.3.47f1/Unity.app/Contents/Managed`.
- e.g. on Linux: `$UNITY_INSTALL_PATH/Hub/Editor/2022.3.47f1/Editor/Data/Managed`.

## NuGettier et al

In case you are using [NuGettier](https://github.com/KageKirin/NuGettier/) or similar tools
to create Unity packages from your NuGet packages,
please make sure to adequately configure them to neither recurse nor include
the assemblies of Unity.Mathematics itself, but rather mark it as dependency.

For NuGettier, you need to add this to its global `.netconfig`:

```toml
[package "unitymathematics.*"] # '.*' is to take in the regex sense, and lowercase is b/c case insensitivity
name = "com.unity.mathematics"
version = "^(?<major>0|[1-9]\\d*)\\.(?<minor>0|[1-9]\\d*)\\.(?<patch>0|[1-9]\\d*)" #only keep major.minor.patch, drop the rest
ignore = false  #do not ignore, as in include-in-dependencies
exclude = true  #exclude, as in do-not-include into amalgamte packages
```
