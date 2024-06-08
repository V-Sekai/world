# project-other-world

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-8-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

The V-Sekai World project aims to create a virtual world using the Godot Engine client and server.

## Fire's Development Timeline

```mermaid
graph TD;
    PR[Project Other World] --> GE((Godot Engine));
    PR --> CL{Client};
    PR --> SE{Server};
    GE --> G4["Godot 4.3 Release<br>Est. July 2024"];
    GE --> G0["Godot 4.0 Release<br>Done March 2023"];
    PR --> CO[Contributors];
    G4 --> SE;
    G4 --> CL;
    UX --> BE;
    CL --> HP;

subgraph "Editor Creator"
    ED{Editor} --> UN["Unidot Unity Package Importer<br>Done March 2023 - May 2024"];
    ED --> FB[FBX];
    ED --> GF["glTF2.0 general release<br>Concurrent with Godot 4.0 Release"];
    ED --> VRM["VRM 1.0<br>Depends on glTF2.0 general release"];
    FB --> G4;
    LY --> FB;
    GF --> G0;
    VR --> GF;
    VRM --> ED;
    ED --> VR;
    ED -->|Upload Avatars| BE;
    BE -->|Load Avatars| CL;
    SE -->|Download Avatars| CL;
    IF --> FB;
end

subgraph "100 Human Players Concurrent"
    BE --> HP;
end

subgraph "Contributors"
    CO --> SA[Saracen];
    SA --> UX["UI/UX Redesign"];
    CO --> IF[iFire];
    CO --> TO[Tokage];
    TO --> AN[3D Animation];
    AN --> G4;
    CO --> LY[lyuma];
    CO --> EW[EnthWyrr];
    CO --> MM[MMMaellon];
    CO --> SI[Silent];
    SI --> UX;
    CO --> BP[Bioblaze Payne];
end
```

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/SaracenOne"><img src="https://avatars.githubusercontent.com/u/12756047?v=4?s=100" width="100px;" alt="Saracen"/><br /><sub><b>Saracen</b></sub></a><br /><a href="https://github.com/V-Sekai/v-sekai-other-world/commits?author=SaracenOne" title="Code">💻</a> <a href="#design-SaracenOne" title="Design">🎨</a> <a href="#ideas-SaracenOne" title="Ideas, Planning, & Feedback">🤔</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://chibifire.com"><img src="https://avatars.githubusercontent.com/u/32321?v=4?s=100" width="100px;" alt="K. S. Ernest (iFire) Lee"/><br /><sub><b>K. S. Ernest (iFire) Lee</b></sub></a><br /><a href="https://github.com/V-Sekai/v-sekai-other-world/commits?author=fire" title="Code">💻</a> <a href="#design-fire" title="Design">🎨</a> <a href="#research-fire" title="Research">🔬</a> <a href="#ideas-fire" title="Ideas, Planning, & Feedback">🤔</a> <a href="#infra-fire" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://tokage.info/lab"><img src="https://avatars.githubusercontent.com/u/61938263?v=4?s=100" width="100px;" alt="Silc Lizard (Tokage) Renew"/><br /><sub><b>Silc Lizard (Tokage) Renew</b></sub></a><br /><a href="#design-TokageItLab" title="Design">🎨</a> <a href="https://github.com/V-Sekai/v-sekai-other-world/commits?author=TokageItLab" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/lyuma"><img src="https://avatars.githubusercontent.com/u/39946030?v=4?s=100" width="100px;" alt="lyuma"/><br /><sub><b>lyuma</b></sub></a><br /><a href="https://github.com/V-Sekai/v-sekai-other-world/commits?author=lyuma" title="Code">💻</a> <a href="#infra-lyuma" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/EnthWyrr"><img src="https://avatars.githubusercontent.com/u/51394825?v=4?s=100" width="100px;" alt="EnthWyrr"/><br /><sub><b>EnthWyrr</b></sub></a><br /><a href="#translation-EnthWyrr" title="Translation">🌍</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MMMaellon"><img src="https://avatars.githubusercontent.com/u/52807725?v=4?s=100" width="100px;" alt="MMMaellon"/><br /><sub><b>MMMaellon</b></sub></a><br /><a href="https://github.com/V-Sekai/v-sekai-other-world/commits?author=MMMaellon" title="Code">💻</a> <a href="#design-MMMaellon" title="Design">🎨</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://s-ilent.gitlab.io/"><img src="https://avatars.githubusercontent.com/u/16026653?v=4?s=100" width="100px;" alt="Silent"/><br /><sub><b>Silent</b></sub></a><br /><a href="#design-s-ilent" title="Design">🎨</a> <a href="#ideas-s-ilent" title="Ideas, Planning, & Feedback">🤔</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/mraarseth"><img src="https://avatars.githubusercontent.com/u/2059119?v=4?s=100" width="100px;" alt="Bioblaze Payne"/><br /><sub><b>Bioblaze Payne</b></sub></a><br /><a href="https://github.com/V-Sekai/v-sekai-other-world/commits?author=Bioblaze" title="Code">💻</a> <a href="#ideas-Bioblaze" title="Ideas, Planning, & Feedback">🤔</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
