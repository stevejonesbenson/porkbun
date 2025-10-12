
<!-- MDOC -->

<p align="center">

</p>

<p align="center">
  <em><strong>Porkbun // </strong></em><br/>
  乾史蒂夫和朋友 //<br/>
  <em><strong>Elixir client for the Porkbun API //</strong></em><br/>
</p>

<p align="center">
  <a href="https://hexdocs.pm/elixir/1.18.4/Kernel.html">
    <img alt="Elixir 1.18.4" src="https://img.shields.io/badge/1.18.4-fbf5f3?&logo=elixir&logoColor=696eff&color=fbf5f3" >
  </a>
  <a href="https://www.erlang.org/docs">
    <img alt="Erlang 28.1" src="https://img.shields.io/badge/28.1-4B275F?&logo=erlang&logoColor=a90432&color=fbf5f3" >
  </a>
</p>

<p align="center">
  <a href="https://hex.pm/packages/porkbun/0.1.0">
  <img alt="HexPM"  src="https://img.shields.io/badge/package-0.1.0-608AC9.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAMAAAAM7l6QAAABuVBMVEVHcEzRzyFSMHvn5CN5u0JnPZfh3xleOJBlO5ROiX2uShplhMNefridGDGlHjqoHzt3uUFwrUCfHTd1sj7krCTpsSSpHzzlqyHdpSDLtyRORRl2tFNkhcGoIDzT0h9igbupIUBmhcN/vkHmqSF5ukFkg792tkDfoyF2tkBigr54u0FlhcLYoiRhgLmsKjpmiLh1tT1hgL6QyFBmhcCpJEZnh8XtujGkHj2lHjlWNHffmSTk4ittQpddOYGiHjlpi7l2tT+qzkR5ukHprB/orSF2tE6sKjmhHjmAO4JjT6FzsT/npCHipx/rrSDrsCOnIDzrsidefLaLxE2VLFqMwU5gaa5zQZHmwi52tkFzrlfhqR7qsCLr6B96vUJnh8WtIT6pHzxiOpRoiMbs6CGnHTrsrR9lhsRxRZtmPJfq5xthOZOGw0jrqx/ssiRmhsR9vkLrsCBrjrevLTfimSTsrx7ttSprP5jrqCDrryFkZbB3tVNker2YykaTMWjb4ibr3x1gOJPrwh3stR+ozzZjSZ18PoqiKVG41jfsyyBiVqWHOHrsvifI3Dd3QZHs1it2tFNqjba0Mj3koCgepG5jAAAAXHRSTlMAIRni/oR82tkFBfYODmXT5w8eH2fU5oYfEgH+o6OSM/Pc86Ojc4QzZ2HV0A4fvLpHQv6H/ef+OocNvuTZGUrAMqu/8sG8vjCZmzPlT/r0f+ca0aNjodusir5D6Q59b3gAAAHTSURBVCjPjdPnX9NAGMDxU4IKnZTSQsvee++hyB6yFJxZgElKkzRRWlqGgKggiIL8xd5deubyjt+r3OebNnkuCQD3quSBoxKntr4ZyaEaeV7g4GD/H5Zlt0nX3eu0Fhf1/zphWXLG8VH3y0KKw6mU/pMlbV+oqlpva8NqykyenRA+PlJVwz9ONL8mpUuS9HUn2zeohlGbl+UXy3pS0rTJ8ke48mqD4wyuujM78pSeSSbT6Zp8a51XyzAcbMIaLmiammRKiw3kYgt+zEyjNZSuaZpphu1bredwzXC4SFjPpDUtU1Rsc2EzZuZtBLz/gO5aWgrS29SI/p1h/J1g+G4XNdxKc8H0wUE0Gr15B9r/fkbNeGh2P/uEuu0AA6GPMFH00ly3heL7ugAYxCr6Ara2VWHle+BxwIdUFAf/a6QHI9/ShlZerEJogHBFH0I+0YRXnnakglBGNrWUx9rhttZPKzFXzuXi5l0IE64u8kDLkApfFGVvExbb30okZLmUPFAwG4La+0NRYojj3w9lWa6qsCdZyf4Y82Z8H3IdtQ0Bn3D+G2oMefw0dii3rNHb5O29UiyOw04vXU2O99zz6vXo6BPUY9yG2/mZDI2NPaQaut+n9w+tc5y3ifUvcgAAAABJRU5ErkJggg==" >
</a>
<a href="https://hexdocs.pm/porkbun/0.1.0">
  <img alt="HexDocs"  src="https://img.shields.io/badge/docs-0.1.0-88B551.svg?logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAMAAAAM7l6QAAABuVBMVEVHcEzRzyFSMHvn5CN5u0JnPZfh3xleOJBlO5ROiX2uShplhMNefridGDGlHjqoHzt3uUFwrUCfHTd1sj7krCTpsSSpHzzlqyHdpSDLtyRORRl2tFNkhcGoIDzT0h9igbupIUBmhcN/vkHmqSF5ukFkg792tkDfoyF2tkBigr54u0FlhcLYoiRhgLmsKjpmiLh1tT1hgL6QyFBmhcCpJEZnh8XtujGkHj2lHjlWNHffmSTk4ittQpddOYGiHjlpi7l2tT+qzkR5ukHprB/orSF2tE6sKjmhHjmAO4JjT6FzsT/npCHipx/rrSDrsCOnIDzrsidefLaLxE2VLFqMwU5gaa5zQZHmwi52tkFzrlfhqR7qsCLr6B96vUJnh8WtIT6pHzxiOpRoiMbs6CGnHTrsrR9lhsRxRZtmPJfq5xthOZOGw0jrqx/ssiRmhsR9vkLrsCBrjrevLTfimSTsrx7ttSprP5jrqCDrryFkZbB3tVNker2YykaTMWjb4ibr3x1gOJPrwh3stR+ozzZjSZ18PoqiKVG41jfsyyBiVqWHOHrsvifI3Dd3QZHs1it2tFNqjba0Mj3koCgepG5jAAAAXHRSTlMAIRni/oR82tkFBfYODmXT5w8eH2fU5oYfEgH+o6OSM/Pc86Ojc4QzZ2HV0A4fvLpHQv6H/ef+OocNvuTZGUrAMqu/8sG8vjCZmzPlT/r0f+ca0aNjodusir5D6Q59b3gAAAHTSURBVCjPjdPnX9NAGMDxU4IKnZTSQsvee++hyB6yFJxZgElKkzRRWlqGgKggiIL8xd5deubyjt+r3OebNnkuCQD3quSBoxKntr4ZyaEaeV7g4GD/H5Zlt0nX3eu0Fhf1/zphWXLG8VH3y0KKw6mU/pMlbV+oqlpva8NqykyenRA+PlJVwz9ONL8mpUuS9HUn2zeohlGbl+UXy3pS0rTJ8ke48mqD4wyuujM78pSeSSbT6Zp8a51XyzAcbMIaLmiammRKiw3kYgt+zEyjNZSuaZpphu1bredwzXC4SFjPpDUtU1Rsc2EzZuZtBLz/gO5aWgrS29SI/p1h/J1g+G4XNdxKc8H0wUE0Gr15B9r/fkbNeGh2P/uEuu0AA6GPMFH00ly3heL7ugAYxCr6Ara2VWHle+BxwIdUFAf/a6QHI9/ShlZerEJogHBFH0I+0YRXnnakglBGNrWUx9rhttZPKzFXzuXi5l0IE64u8kDLkApfFGVvExbb30okZLmUPFAwG4La+0NRYojj3w9lWa6qsCdZyf4Y82Z8H3IdtQ0Bn3D+G2oMefw0dii3rNHb5O29UiyOw04vXU2O99zz6vXo6BPUY9yG2/mZDI2NPaQaut+n9w+tc5y3ifUvcgAAAABJRU5ErkJggg==" >
</a>
<br /><a href="https://github.com/stevejonesbenson/porkbun">
  <img alt="GitHub" src="https://img.shields.io/badge/stevejonesbenson-porkbun-fbf5f3.svg?logo=github" >
</a>
 <img alt="Type Library" src="https://img.shields.io/badge/apm-Library-ff6188.svg?logo=bugatti" >

</p>

<p align="center">
<!-- CI -->
  <a href="https://github.com/stevejonesbenson/porkbun/actions/workflows/ci.yml">
    <img alt="CI" src="https://github.com/stevejonesbenson/porkbun/actions/workflows/ci.yml/badge.svg?branch=master" >
  </a>
<!-- CI -->
<a href="https://codecov.io/gh/stevejonesbenson/porkbun">
  <img alt="Coverage" src="https://codecov.io/gh/stevejonesbenson/porkbun/branch/master/graph/badge.svg?token=Ute1yYEWvt" >
</a>

<p>
  <a href="https://codecov.io/gh/stevejonesbenson/porkbun">
    <img alt="Coverage" src="https://codecov.io/gh/stevejonesbenson/porkbun/branch/master/graphs/icicle.svg?token=Ute1yYEWvt">
  </a>
</p>

</p>
<!--  Text below will be included in the README.md and excluded from the main moduledoc -->

<!-- MDOC -->

## Contributions

<!-- INSTALL -->

## Installation

Add the package to your deps.

    {porkbun, "~> 0.1.0"}

<!-- INSTALL -->
