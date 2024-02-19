# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v13.1.0](https://github.com/voxpupuli/puppet-grafana/tree/v13.1.0) (2023-10-31)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v13.0.1...v13.1.0)

**Implemented enhancements:**

- Add OracleLinux support [\#340](https://github.com/voxpupuli/puppet-grafana/pull/340) ([bastelfreak](https://github.com/bastelfreak))

## [v13.0.1](https://github.com/voxpupuli/puppet-grafana/tree/v13.0.1) (2023-09-15)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v13.0.0...v13.0.1)

**Fixed bugs:**

- Update Debian repo signing key [\#335](https://github.com/voxpupuli/puppet-grafana/pull/335) ([mouchymouchy](https://github.com/mouchymouchy))

## [v13.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v13.0.0) (2023-06-22)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v12.0.0...v13.0.0)

**Breaking changes:**

- puppetlabs/stdlib: Require 9.x [\#325](https://github.com/voxpupuli/puppet-grafana/pull/325) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Ubuntu 22.04 support [\#329](https://github.com/voxpupuli/puppet-grafana/pull/329) ([bastelfreak](https://github.com/bastelfreak))
- Add EL9 support [\#328](https://github.com/voxpupuli/puppet-grafana/pull/328) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- cleanup .fixtures.yml [\#326](https://github.com/voxpupuli/puppet-grafana/pull/326) ([bastelfreak](https://github.com/bastelfreak))

## [v12.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v12.0.0) (2023-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v11.2.0...v12.0.0)

**Breaking changes:**

- puppet/archive: Allow 7.x; puppetlabs/stdlib: Require 9.x [\#322](https://github.com/voxpupuli/puppet-grafana/pull/322) ([bastelfreak](https://github.com/bastelfreak))
- Drop Puppet 6 support [\#320](https://github.com/voxpupuli/puppet-grafana/pull/320) ([bastelfreak](https://github.com/bastelfreak))

## [v11.2.0](https://github.com/voxpupuli/puppet-grafana/tree/v11.2.0) (2023-03-30)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v11.1.0...v11.2.0)

**Implemented enhancements:**

- Add AlmaLinux 8 support [\#312](https://github.com/voxpupuli/puppet-grafana/pull/312) ([bastelfreak](https://github.com/bastelfreak))
- Add Rocky 8 support [\#311](https://github.com/voxpupuli/puppet-grafana/pull/311) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- Fix default PGP key [\#308](https://github.com/voxpupuli/puppet-grafana/pull/308) ([smortex](https://github.com/smortex))

**Closed issues:**

- repository setup: new GPG repository keys [\#307](https://github.com/voxpupuli/puppet-grafana/issues/307)
- Failure to install Grafana using module on fresh install of Debian 11 [\#278](https://github.com/voxpupuli/puppet-grafana/issues/278)

**Merged pull requests:**

- Disable beta packages tests on Debian [\#316](https://github.com/voxpupuli/puppet-grafana/pull/316) ([smortex](https://github.com/smortex))
- Update repo urls [\#314](https://github.com/voxpupuli/puppet-grafana/pull/314) ([promasu](https://github.com/promasu))
- Move static default settings from Hiera to Puppet [\#309](https://github.com/voxpupuli/puppet-grafana/pull/309) ([smortex](https://github.com/smortex))

## [v11.1.0](https://github.com/voxpupuli/puppet-grafana/tree/v11.1.0) (2022-11-02)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v11.0.0...v11.1.0)

**Implemented enhancements:**

- Refactor `grafana_datasource` and add `uid` property [\#301](https://github.com/voxpupuli/puppet-grafana/pull/301) ([alexjfisher](https://github.com/alexjfisher))

**Fixed bugs:**

- Do not show datasource config changes [\#296](https://github.com/voxpupuli/puppet-grafana/pull/296) ([fklajn](https://github.com/fklajn))

**Closed issues:**

- `grafana_folder` `permissions` not idempotent [\#304](https://github.com/voxpupuli/puppet-grafana/issues/304)
- 'uid' property is not included in datasource provisioning [\#229](https://github.com/voxpupuli/puppet-grafana/issues/229)

**Merged pull requests:**

- Update the link to the toml gem [\#303](https://github.com/voxpupuli/puppet-grafana/pull/303) ([16c7x](https://github.com/16c7x))

## [v11.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v11.0.0) (2022-08-17)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v10.0.1...v11.0.0)

**Breaking changes:**

- Disable Arch Linux testing [\#292](https://github.com/voxpupuli/puppet-grafana/pull/292) ([bastelfreak](https://github.com/bastelfreak))
- Remove `address` param from `grafana_organization` [\#284](https://github.com/voxpupuli/puppet-grafana/pull/284) ([alexjfisher](https://github.com/alexjfisher))

**Implemented enhancements:**

- Switch documentation to puppet strings [\#294](https://github.com/voxpupuli/puppet-grafana/pull/294) ([SimonHoenscheid](https://github.com/SimonHoenscheid))
- Add support for custom repository URL [\#291](https://github.com/voxpupuli/puppet-grafana/pull/291) ([SimonHoenscheid](https://github.com/SimonHoenscheid))
- Add `organizations` property to `grafana_user` [\#286](https://github.com/voxpupuli/puppet-grafana/pull/286) ([alexjfisher](https://github.com/alexjfisher))
- Fix performance of `grafana_user` [\#285](https://github.com/voxpupuli/puppet-grafana/pull/285) ([alexjfisher](https://github.com/alexjfisher))
- Accept `Sensitive` `ldap_cfg` [\#282](https://github.com/voxpupuli/puppet-grafana/pull/282) ([alexjfisher](https://github.com/alexjfisher))
- Accept `Sensitive` `cfg` [\#280](https://github.com/voxpupuli/puppet-grafana/pull/280) ([alexjfisher](https://github.com/alexjfisher))

**Fixed bugs:**

- Fix `grafana_user` and switch to using `flush` [\#283](https://github.com/voxpupuli/puppet-grafana/pull/283) ([alexjfisher](https://github.com/alexjfisher))
- Set grafana.ini owner to root with packages [\#264](https://github.com/voxpupuli/puppet-grafana/pull/264) ([ekohl](https://github.com/ekohl))

**Merged pull requests:**

- Remove outdated `Integer note` from README [\#281](https://github.com/voxpupuli/puppet-grafana/pull/281) ([alexjfisher](https://github.com/alexjfisher))

## [v10.0.1](https://github.com/voxpupuli/puppet-grafana/tree/v10.0.1) (2021-12-02)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v10.0.0...v10.0.1)

**Fixed bugs:**

- Grafana\_datasource no longer idempotent [\#270](https://github.com/voxpupuli/puppet-grafana/issues/270)
- Add support for HTTP operation PATCH to fix grafana\_membership [\#266](https://github.com/voxpupuli/puppet-grafana/pull/266) ([dgoetz](https://github.com/dgoetz))

**Merged pull requests:**

- Fix rubocop after disabling BooleanSymbol cop [\#271](https://github.com/voxpupuli/puppet-grafana/pull/271) ([root-expert](https://github.com/root-expert))
- Correct type for the example [\#265](https://github.com/voxpupuli/puppet-grafana/pull/265) ([earthgecko](https://github.com/earthgecko))

## [v10.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v10.0.0) (2021-11-26)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v9.0.1...v10.0.0)

**Breaking changes:**

- Drop support for Debian 9, Ubuntu 16.04 \(EOL\) [\#262](https://github.com/voxpupuli/puppet-grafana/pull/262) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Add support for Debian 11, CentOS 8, RedHat 8 and FreeBSD 13 [\#255](https://github.com/voxpupuli/puppet-grafana/pull/255) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Fix dashboard api call in grafana\_dashboard [\#267](https://github.com/voxpupuli/puppet-grafana/pull/267) ([joernott](https://github.com/joernott))

**Closed issues:**

- grafana\_dashboards ov version 9.0.1 does not work with Grafana 6.7.6 [\#261](https://github.com/voxpupuli/puppet-grafana/issues/261)

## [v9.0.1](https://github.com/voxpupuli/puppet-grafana/tree/v9.0.1) (2021-08-26)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v9.0.0...v9.0.1)

**Merged pull requests:**

- Allow stdlib 8.0.0 and archive 6.0.0 [\#252](https://github.com/voxpupuli/puppet-grafana/pull/252) ([smortex](https://github.com/smortex))

## [v9.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v9.0.0) (2021-08-17)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v8.0.0...v9.0.0)

**Breaking changes:**

- Support only 6.x/7.x/8.x versions [\#246](https://github.com/voxpupuli/puppet-grafana/pull/246) ([root-expert](https://github.com/root-expert))
- bump default grafana version for FreeBSD [\#240](https://github.com/voxpupuli/puppet-grafana/pull/240) ([olevole](https://github.com/olevole))

**Implemented enhancements:**

- puppetlabs/stdlib: Allow 7.x [\#244](https://github.com/voxpupuli/puppet-grafana/pull/244) ([bastelfreak](https://github.com/bastelfreak))
- puppet/archive: allow 5.x [\#243](https://github.com/voxpupuli/puppet-grafana/pull/243) ([bastelfreak](https://github.com/bastelfreak))
- Allow grafana\_team home dashboard to be scoped to a folder [\#241](https://github.com/voxpupuli/puppet-grafana/pull/241) ([treydock](https://github.com/treydock))

**Closed issues:**

- config class does not restart service [\#239](https://github.com/voxpupuli/puppet-grafana/issues/239)
- grafana\_team resource gives Could not evaluate: Invalid parameter  [\#237](https://github.com/voxpupuli/puppet-grafana/issues/237)

**Merged pull requests:**

- Update README.md about tested OSes [\#250](https://github.com/voxpupuli/puppet-grafana/pull/250) ([bastelfreak](https://github.com/bastelfreak))
- Use Iterable.find to find a folder [\#249](https://github.com/voxpupuli/puppet-grafana/pull/249) ([ekohl](https://github.com/ekohl))
- Add Ubuntu 20.04 support [\#248](https://github.com/voxpupuli/puppet-grafana/pull/248) ([root-expert](https://github.com/root-expert))
- Update badges in README.md [\#245](https://github.com/voxpupuli/puppet-grafana/pull/245) ([bastelfreak](https://github.com/bastelfreak))

## [v8.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v8.0.0) (2021-02-20)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v7.0.0...v8.0.0)

**Breaking changes:**

- Drop EoL Debian 8 support [\#233](https://github.com/voxpupuli/puppet-grafana/pull/233) ([bastelfreak](https://github.com/bastelfreak))
- Drop Eol CentOS 6 support [\#232](https://github.com/voxpupuli/puppet-grafana/pull/232) ([bastelfreak](https://github.com/bastelfreak))
- Mask/redact password and secure\_json\_data in grafana\_datasource; require at least puppet 6.1.0 [\#221](https://github.com/voxpupuli/puppet-grafana/pull/221) ([nmaludy](https://github.com/nmaludy))

**Implemented enhancements:**

- Enable Puppet 7 support [\#234](https://github.com/voxpupuli/puppet-grafana/pull/234) ([bastelfreak](https://github.com/bastelfreak))
- Allow multiple puppetsource [\#224](https://github.com/voxpupuli/puppet-grafana/pull/224) ([jsfrerot](https://github.com/jsfrerot))

**Fixed bugs:**

- Fix `puppet generate types` [\#227](https://github.com/voxpupuli/puppet-grafana/pull/227) ([smortex](https://github.com/smortex))
- Ensure all API types have grafana\_conn\_validator autorequires [\#226](https://github.com/voxpupuli/puppet-grafana/pull/226) ([treydock](https://github.com/treydock))
- Don't manage dashboard path when puppetsource is not set [\#225](https://github.com/voxpupuli/puppet-grafana/pull/225) ([treydock](https://github.com/treydock))

**Closed issues:**

- Feature Request: Support for Grafana Plugin install by URL [\#173](https://github.com/voxpupuli/puppet-grafana/issues/173)
- add/change sourceselect option for provisioning\_dashboards [\#130](https://github.com/voxpupuli/puppet-grafana/issues/130)

**Merged pull requests:**

- Fix types to work with 'puppet generate types' [\#236](https://github.com/voxpupuli/puppet-grafana/pull/236) ([treydock](https://github.com/treydock))
- Rebase plugin from zip patch [\#235](https://github.com/voxpupuli/puppet-grafana/pull/235) ([XMol](https://github.com/XMol))
- Bugfix for teams, update README and acceptance testing [\#215](https://github.com/voxpupuli/puppet-grafana/pull/215) ([MorningLightMountain713](https://github.com/MorningLightMountain713))

## [v7.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v7.0.0) (2020-08-24)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v6.2.0...v7.0.0)

## [v6.2.0](https://github.com/voxpupuli/puppet-grafana/tree/v6.2.0) (2020-08-23)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v6.1.0...v6.2.0)

**Breaking changes:**

- drop Ubuntu 14.04 support [\#192](https://github.com/voxpupuli/puppet-grafana/pull/192) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- add SLES support [\#220](https://github.com/voxpupuli/puppet-grafana/pull/220) ([tuxmea](https://github.com/tuxmea))
- Support for teams, dashboard permissions and memberships [\#210](https://github.com/voxpupuli/puppet-grafana/pull/210) ([MorningLightMountain713](https://github.com/MorningLightMountain713))
- Add mechanism to make API changes once API is available [\#208](https://github.com/voxpupuli/puppet-grafana/pull/208) ([treydock](https://github.com/treydock))
- Update list of supported operating systems [\#204](https://github.com/voxpupuli/puppet-grafana/pull/204) ([dhoppe](https://github.com/dhoppe))
- allow connecting to multiple LDAP services [\#199](https://github.com/voxpupuli/puppet-grafana/pull/199) ([unki](https://github.com/unki))

**Fixed bugs:**

- Code in maifests/service.pp refers to code from manifests/params.pp [\#206](https://github.com/voxpupuli/puppet-grafana/issues/206)
- Grafana 5.0.3 Users passwords being set and datasources created on every puppet run [\#104](https://github.com/voxpupuli/puppet-grafana/issues/104)
- Clean up code, because params.pp has been removed [\#214](https://github.com/voxpupuli/puppet-grafana/pull/214) ([dhoppe](https://github.com/dhoppe))

**Closed issues:**

- Grafana folder example doc update [\#197](https://github.com/voxpupuli/puppet-grafana/issues/197)

**Merged pull requests:**

- Fix `grafana_user` `password` idempotency [\#211](https://github.com/voxpupuli/puppet-grafana/pull/211) ([alexjfisher](https://github.com/alexjfisher))
- Support managing folder permissions [\#207](https://github.com/voxpupuli/puppet-grafana/pull/207) ([treydock](https://github.com/treydock))
- \#197 Minor Doc correction - grafana\_folder [\#198](https://github.com/voxpupuli/puppet-grafana/pull/198) ([RandellP](https://github.com/RandellP))
- Do not restart grafana on provisioned dashboard updates [\#196](https://github.com/voxpupuli/puppet-grafana/pull/196) ([treydock](https://github.com/treydock))
- Remove duplicate CONTRIBUTING.md file [\#193](https://github.com/voxpupuli/puppet-grafana/pull/193) ([dhoppe](https://github.com/dhoppe))

## [v6.1.0](https://github.com/voxpupuli/puppet-grafana/tree/v6.1.0) (2019-10-30)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v6.0.0...v6.1.0)

**Implemented enhancements:**

- Feature request: add basicAuth for grafana\_datasource [\#43](https://github.com/voxpupuli/puppet-grafana/issues/43)
- Add FreeBSD 12 support [\#179](https://github.com/voxpupuli/puppet-grafana/pull/179) ([olevole](https://github.com/olevole))
- Update grafana\_dashboard resource for folders [\#172](https://github.com/voxpupuli/puppet-grafana/pull/172) ([alexconrey](https://github.com/alexconrey))
- Implement grafana\_folder resource type [\#170](https://github.com/voxpupuli/puppet-grafana/pull/170) ([alexconrey](https://github.com/alexconrey))
- Mark passwords as sensitive [\#165](https://github.com/voxpupuli/puppet-grafana/pull/165) ([alexjfisher](https://github.com/alexjfisher))

**Fixed bugs:**

- Fix version, because 6.0.0-beta1 does not exist anymore [\#163](https://github.com/voxpupuli/puppet-grafana/pull/163) ([dhoppe](https://github.com/dhoppe))
- Fix value of variables base\_url and real\_archive\_source [\#161](https://github.com/voxpupuli/puppet-grafana/pull/161) ([dhoppe](https://github.com/dhoppe))
- Fix value of variable real\_package\_source [\#160](https://github.com/voxpupuli/puppet-grafana/pull/160) ([dhoppe](https://github.com/dhoppe))

**Closed issues:**

- How to create Notification channels [\#188](https://github.com/voxpupuli/puppet-grafana/issues/188)
- Cannot install puppet/grafana, most recent puppet/archive version is v4.2 [\#184](https://github.com/voxpupuli/puppet-grafana/issues/184)
- \[UBUNTU 14.04\] Package not found [\#85](https://github.com/voxpupuli/puppet-grafana/issues/85)
- Puppet module exposes passwords - current and previous in plane text during puppet runs [\#82](https://github.com/voxpupuli/puppet-grafana/issues/82)
- using docker install with container\_cfg attempts to use incorrect permissions [\#52](https://github.com/voxpupuli/puppet-grafana/issues/52)
- Hide sensitive data values [\#45](https://github.com/voxpupuli/puppet-grafana/issues/45)
- Feature request: support auth.proxy config option [\#40](https://github.com/voxpupuli/puppet-grafana/issues/40)

**Merged pull requests:**

- Clean up acceptance spec helper [\#189](https://github.com/voxpupuli/puppet-grafana/pull/189) ([ekohl](https://github.com/ekohl))
- DOC Add Provisioning with dashboards from grafana.com [\#185](https://github.com/voxpupuli/puppet-grafana/pull/185) ([mfaure](https://github.com/mfaure))
- Allow puppet/archive 4.x and puppetlabs/stdlib 6.x [\#176](https://github.com/voxpupuli/puppet-grafana/pull/176) ([alexjfisher](https://github.com/alexjfisher))
- Corrected invalid database config example [\#169](https://github.com/voxpupuli/puppet-grafana/pull/169) ([Rovanion](https://github.com/Rovanion))
- Use data in modules instead of params.pp [\#167](https://github.com/voxpupuli/puppet-grafana/pull/167) ([dhoppe](https://github.com/dhoppe))
- Remove Puppet 3 specific syntax [\#166](https://github.com/voxpupuli/puppet-grafana/pull/166) ([dhoppe](https://github.com/dhoppe))

## [v6.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v6.0.0) (2019-02-14)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v5.0.0...v6.0.0)

**Breaking changes:**

- modulesync 2.5.1 and drop Puppet 4 [\#154](https://github.com/voxpupuli/puppet-grafana/pull/154) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add a task for setting the admin user's password [\#148](https://github.com/voxpupuli/puppet-grafana/pull/148) ([genebean](https://github.com/genebean))
- Integration notification channels [\#144](https://github.com/voxpupuli/puppet-grafana/pull/144) ([jnguiot](https://github.com/jnguiot))

**Fixed bugs:**

- Update repo\_name Enum for new 'beta' repo [\#155](https://github.com/voxpupuli/puppet-grafana/pull/155) ([JayH5](https://github.com/JayH5))
- Fix \#152 : multi arch send out a notice [\#153](https://github.com/voxpupuli/puppet-grafana/pull/153) ([elfranne](https://github.com/elfranne))
- fixes repo url and key [\#150](https://github.com/voxpupuli/puppet-grafana/pull/150) ([crazymind1337](https://github.com/crazymind1337))

**Closed issues:**

- multi arch send out a notice [\#152](https://github.com/voxpupuli/puppet-grafana/issues/152)
- Package Repo moved to packages.grafana.com [\#149](https://github.com/voxpupuli/puppet-grafana/issues/149)
- install\_mode archive fails if $data\_dir is not manually created [\#142](https://github.com/voxpupuli/puppet-grafana/issues/142)

**Merged pull requests:**

- include classes without leading :: [\#157](https://github.com/voxpupuli/puppet-grafana/pull/157) ([bastelfreak](https://github.com/bastelfreak))
- replace deprecated has\_key\(\) with `in` [\#147](https://github.com/voxpupuli/puppet-grafana/pull/147) ([bastelfreak](https://github.com/bastelfreak))
- archive install\_method creates data\_dir [\#143](https://github.com/voxpupuli/puppet-grafana/pull/143) ([othalla](https://github.com/othalla))
- Fix folder typos [\#140](https://github.com/voxpupuli/puppet-grafana/pull/140) ([pfree](https://github.com/pfree))

## [v5.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v5.0.0) (2018-10-06)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.5.0...v5.0.0)

**Breaking changes:**

- Change default of version parameter to 'installed' [\#126](https://github.com/voxpupuli/puppet-grafana/pull/126) ([baurmatt](https://github.com/baurmatt))

**Implemented enhancements:**

- removing value restriction on grafana\_datasource so any custom plugin can be used [\#136](https://github.com/voxpupuli/puppet-grafana/pull/136) ([lukebigum](https://github.com/lukebigum))
- add --repo option to grafana\_cli plugin install [\#132](https://github.com/voxpupuli/puppet-grafana/pull/132) ([rwuest](https://github.com/rwuest))
- Parametrize provisioning file names [\#128](https://github.com/voxpupuli/puppet-grafana/pull/128) ([kazeborja](https://github.com/kazeborja))

**Closed issues:**

- Version parameter should default to 'installed' [\#125](https://github.com/voxpupuli/puppet-grafana/issues/125)

**Merged pull requests:**

- modulesync 2.1.0 and allow puppet 6.x [\#137](https://github.com/voxpupuli/puppet-grafana/pull/137) ([bastelfreak](https://github.com/bastelfreak))
- allow puppetlabs/stdlib 5.x and puppetlabs/apt 6.x [\#134](https://github.com/voxpupuli/puppet-grafana/pull/134) ([bastelfreak](https://github.com/bastelfreak))

## [v4.5.0](https://github.com/voxpupuli/puppet-grafana/tree/v4.5.0) (2018-07-16)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.4.1...v4.5.0)

**Implemented enhancements:**

- Use provisioning backend for dashboards, providers [\#103](https://github.com/voxpupuli/puppet-grafana/issues/103)
- Feature: Add grafana provisioning to this module. [\#120](https://github.com/voxpupuli/puppet-grafana/pull/120) ([drshawnkwang](https://github.com/drshawnkwang))

**Closed issues:**

- Any plan to update module to use the grafana provisioning by yaml files ? [\#122](https://github.com/voxpupuli/puppet-grafana/issues/122)

## [v4.4.1](https://github.com/voxpupuli/puppet-grafana/tree/v4.4.1) (2018-07-04)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.4.0...v4.4.1)

**Fixed bugs:**

- Fix dependency in provisioning plugins [\#118](https://github.com/voxpupuli/puppet-grafana/pull/118) ([drshawnkwang](https://github.com/drshawnkwang))

**Closed issues:**

- grafana plugin install/check breaks catalog run when grafana-server service is not running [\#79](https://github.com/voxpupuli/puppet-grafana/issues/79)

## [v4.4.0](https://github.com/voxpupuli/puppet-grafana/tree/v4.4.0) (2018-06-21)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.3.0...v4.4.0)

**Implemented enhancements:**

- Manage sysconfig files [\#115](https://github.com/voxpupuli/puppet-grafana/pull/115) ([ZeroPointEnergy](https://github.com/ZeroPointEnergy))

**Merged pull requests:**

- bump archive upper version boundary to \<4.0.0 [\#116](https://github.com/voxpupuli/puppet-grafana/pull/116) ([bastelfreak](https://github.com/bastelfreak))

## [v4.3.0](https://github.com/voxpupuli/puppet-grafana/tree/v4.3.0) (2018-06-18)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.2.0...v4.3.0)

**Implemented enhancements:**

- Add postgres support and secure\_json\_data support [\#105](https://github.com/voxpupuli/puppet-grafana/pull/105) ([Faffnir](https://github.com/Faffnir))

**Fixed bugs:**

- Update release codename from jessie to stretch. [\#113](https://github.com/voxpupuli/puppet-grafana/pull/113) ([drshawnkwang](https://github.com/drshawnkwang))

**Closed issues:**

- puppet-grafana Debian repository should use codename stretch [\#112](https://github.com/voxpupuli/puppet-grafana/issues/112)

**Merged pull requests:**

- drop EOL OSs; fix puppet version range [\#109](https://github.com/voxpupuli/puppet-grafana/pull/109) ([bastelfreak](https://github.com/bastelfreak))
- Rely on beaker-hostgenerator for docker nodesets [\#108](https://github.com/voxpupuli/puppet-grafana/pull/108) ([ekohl](https://github.com/ekohl))
- switch from topscope facts to $facts hash [\#102](https://github.com/voxpupuli/puppet-grafana/pull/102) ([bastelfreak](https://github.com/bastelfreak))
- Update README.md [\#99](https://github.com/voxpupuli/puppet-grafana/pull/99) ([cclloyd](https://github.com/cclloyd))

## [v4.2.0](https://github.com/voxpupuli/puppet-grafana/tree/v4.2.0) (2018-03-06)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.1.1...v4.2.0)

**Implemented enhancements:**

- Create organization  [\#71](https://github.com/voxpupuli/puppet-grafana/issues/71)
- Expand organization property for dashboards [\#94](https://github.com/voxpupuli/puppet-grafana/pull/94) ([brandonrdn](https://github.com/brandonrdn))
- Add grafana\_api\_path to allow for API sub-paths [\#93](https://github.com/voxpupuli/puppet-grafana/pull/93) ([brandonrdn](https://github.com/brandonrdn))

## [v4.1.1](https://github.com/voxpupuli/puppet-grafana/tree/v4.1.1) (2018-02-21)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.1.0...v4.1.1)

**Fixed bugs:**

- grafana\_datasource provider with\_credentials\(\) returns is\_default value [\#89](https://github.com/voxpupuli/puppet-grafana/issues/89)
- fix datasource provider error [\#90](https://github.com/voxpupuli/puppet-grafana/pull/90) ([brandonrdn](https://github.com/brandonrdn))

## [v4.1.0](https://github.com/voxpupuli/puppet-grafana/tree/v4.1.0) (2018-02-03)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.0.3...v4.1.0)

**Implemented enhancements:**

- \(SIMP-4206\) Added organization provider and updated datasource provider [\#86](https://github.com/voxpupuli/puppet-grafana/pull/86) ([heliocentric](https://github.com/heliocentric))

**Closed issues:**

- "Could not autoload" error in grafana\_dashboard with ruby 2.4 on Centos 6 [\#83](https://github.com/voxpupuli/puppet-grafana/issues/83)

## [v4.0.3](https://github.com/voxpupuli/puppet-grafana/tree/v4.0.3) (2017-12-09)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.0.2...v4.0.3)

**Closed issues:**

- Apt key add gets called every run [\#77](https://github.com/voxpupuli/puppet-grafana/issues/77)
- Getting rid or changing the url check for grafana datasource url's [\#75](https://github.com/voxpupuli/puppet-grafana/issues/75)

**Merged pull requests:**

- Update readme with examples of using datasource and dashboard [\#80](https://github.com/voxpupuli/puppet-grafana/pull/80) ([devcfgc](https://github.com/devcfgc))
- Removing the datasource url check as it leads to errors with postgres… [\#76](https://github.com/voxpupuli/puppet-grafana/pull/76) ([Faffnir](https://github.com/Faffnir))

## [v4.0.2](https://github.com/voxpupuli/puppet-grafana/tree/v4.0.2) (2017-10-12)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.0.1...v4.0.2)

**Implemented enhancements:**

- bump archive upper boundary to work with latest versions [\#73](https://github.com/voxpupuli/puppet-grafana/pull/73) ([bastelfreak](https://github.com/bastelfreak))
- add debian 8 and 9 support [\#72](https://github.com/voxpupuli/puppet-grafana/pull/72) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- fix typo in metadata \(redhat 6 twice vs 6/7\) [\#69](https://github.com/voxpupuli/puppet-grafana/pull/69) ([wyardley](https://github.com/wyardley))

## [v4.0.1](https://github.com/voxpupuli/puppet-grafana/tree/v4.0.1) (2017-09-22)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v4.0.0...v4.0.1)

**Fixed bugs:**

- Module doesn't work on Ubuntu Xenial [\#56](https://github.com/voxpupuli/puppet-grafana/issues/56)

## [v4.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v4.0.0) (2017-09-20)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v3.0.0...v4.0.0)

**Breaking changes:**

- BREAKING: Switch to Puppet Data Types \(ldap\_cfg is now undef when disabled\) [\#66](https://github.com/voxpupuli/puppet-grafana/pull/66) ([wyardley](https://github.com/wyardley))
- BREAKING: Create grafana\_plugin resource type and change grafana::plugins [\#63](https://github.com/voxpupuli/puppet-grafana/pull/63) ([wyardley](https://github.com/wyardley))
- BREAKING: Update default Grafana version to 4.5.1 and improve acceptance tests [\#61](https://github.com/voxpupuli/puppet-grafana/pull/61) ([wyardley](https://github.com/wyardley))

**Implemented enhancements:**

- grafana\_user custom resource [\#60](https://github.com/voxpupuli/puppet-grafana/pull/60) ([atward](https://github.com/atward))
- Support newer versions of puppetlabs/apt module [\#53](https://github.com/voxpupuli/puppet-grafana/pull/53) ([ghoneycutt](https://github.com/ghoneycutt))
- Support custom plugins [\#44](https://github.com/voxpupuli/puppet-grafana/pull/44) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- gpg key error on CentOS 7 with default params [\#59](https://github.com/voxpupuli/puppet-grafana/issues/59)
- wget called even if not necessary [\#54](https://github.com/voxpupuli/puppet-grafana/issues/54)
- Fix typo in provider [\#58](https://github.com/voxpupuli/puppet-grafana/pull/58) ([atward](https://github.com/atward))

**Closed issues:**

- install\_method 'docker" ignores all other configurations [\#51](https://github.com/voxpupuli/puppet-grafana/issues/51)
- Usable for Grafana 4.x? [\#37](https://github.com/voxpupuli/puppet-grafana/issues/37)
- Remove docker dependency [\#22](https://github.com/voxpupuli/puppet-grafana/issues/22)

**Merged pull requests:**

- Update README.md [\#67](https://github.com/voxpupuli/puppet-grafana/pull/67) ([wyardley](https://github.com/wyardley))
- Get rid of the dependency on 'wget' module in favor of puppet-archive [\#65](https://github.com/voxpupuli/puppet-grafana/pull/65) ([wyardley](https://github.com/wyardley))
- Remove licenses from the top of files [\#64](https://github.com/voxpupuli/puppet-grafana/pull/64) ([wyardley](https://github.com/wyardley))
- Release 4.0.0 [\#62](https://github.com/voxpupuli/puppet-grafana/pull/62) ([bastelfreak](https://github.com/bastelfreak))
- Always use jessie apt repo when osfamily is Debian. [\#41](https://github.com/voxpupuli/puppet-grafana/pull/41) ([furhouse](https://github.com/furhouse))

## [v3.0.0](https://github.com/voxpupuli/puppet-grafana/tree/v3.0.0) (2017-03-29)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.3...v3.0.0)

**Implemented enhancements:**

- implement package\_ensure param for archlinux [\#34](https://github.com/voxpupuli/puppet-grafana/pull/34) ([bastelfreak](https://github.com/bastelfreak))

**Fixed bugs:**

- FIX configuration file ownership [\#30](https://github.com/voxpupuli/puppet-grafana/pull/30) ([c10l](https://github.com/c10l))

**Closed issues:**

- Configured grafana debian repo should contain current distribution [\#27](https://github.com/voxpupuli/puppet-grafana/issues/27)
- Error while creating dashboard [\#25](https://github.com/voxpupuli/puppet-grafana/issues/25)

**Merged pull requests:**

- Bump version, Update changelog [\#38](https://github.com/voxpupuli/puppet-grafana/pull/38) ([dhoppe](https://github.com/dhoppe))
- Debian and RedHat based operating systems should use the repository by default [\#36](https://github.com/voxpupuli/puppet-grafana/pull/36) ([dhoppe](https://github.com/dhoppe))
- Add support for archlinux [\#32](https://github.com/voxpupuli/puppet-grafana/pull/32) ([bastelfreak](https://github.com/bastelfreak))
- Fix grafana\_dashboards [\#31](https://github.com/voxpupuli/puppet-grafana/pull/31) ([c10l](https://github.com/c10l))
- supoort jessie for install method repo [\#28](https://github.com/voxpupuli/puppet-grafana/pull/28) ([roock](https://github.com/roock))
- Use operatinsystemmajrelease fact in repo url [\#24](https://github.com/voxpupuli/puppet-grafana/pull/24) ([mirekys](https://github.com/mirekys))
- The puppet 4-only release will start at 3.0.0 [\#21](https://github.com/voxpupuli/puppet-grafana/pull/21) ([rnelson0](https://github.com/rnelson0))

## [v2.6.3](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.3) (2017-01-18)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.2...v2.6.3)

## [v2.6.2](https://github.com/voxpupuli/puppet-grafana/tree/v2.6.2) (2017-01-18)

[Full Changelog](https://github.com/voxpupuli/puppet-grafana/compare/v2.6.1...v2.6.2)

## v2.6.1 (2017-01-18)

Just a notice: The next release will be a major one without Puppet 3 support!
This is the last Release that supports it!

## Releasing v2.6.0 (2017-01-18)

**Enhancements**

* add two types & provider: `grafana_datasource` & `grafana_dashboard` these
 type allow configuration of the datasource and the dashboard against the API
* allow configuration of `repo_name` for all installation methods
* be more conservative when installing from docker, while also allowing users to
  override our `stable` choice

**Fixes**

* ensure correct ownership of downloaded artefact
* fix use-before definition of `$version`: https://github.com/bfraser/puppet-grafana/issues/87

**Behind The Scenes**

* switch to voxpupuli/archive from camptocamp

**Changes since forking from bfraser/puppet-grafana**

* Add CONTRIBUTING.MD as well as our issues, spec etc… templates
* update README and other files to point to forked repository
* Rubocop and ruby-lint style-fixes!
* test with puppet > 4.x

## 2.5.0 (2015-10-31)

**Enhancements**
- Support for [Grafana 2.5](http://grafana.org/blog/2015/10/28/Grafana-2-5-Released.html). This is just a version bump to reflect that Grafana 2.5 is now installed by default
- [PR #58](https://github.com/bfraser/puppet-grafana/pull/58) Sort ```cfg``` keys so ```config.ini``` content is not updated every Puppet run

**Fixes**
- [Issue #52](https://github.com/bfraser/puppet-grafana/issues/52) Version logic moved to ```init.pp``` so overriding the version of Grafana to install works as intended

**Behind The Scenes**

- [PR #59](https://github.com/bfraser/puppet-grafana/pull/59) More specific version requirements in ```metadata.json``` due to use of ```contain``` function
- [PR #61](https://github.com/bfraser/puppet-grafana/pull/61) Fixed typos in ```metadata.json```

## 2.1.0 (2015-08-07)

**Enhancements**
- Support for [Grafana 2.1](http://grafana.org/blog/2015/08/04/Grafana-2-1-Released.html)
- [Issue #40](https://github.com/bfraser/puppet-grafana/issues/40) Support for [LDAP integration](http://docs.grafana.org/v2.1/installation/ldap/)
- [PR #34](https://github.com/bfraser/puppet-grafana/pull/34) Support for 'repo' install method to install packages from [packagecloud](https://packagecloud.io/grafana) repositories
- Addition of boolean parameter ```manage_package_repo``` to control whether the module will manage the package repository when using the 'repo' install method. See README.md for details
- [PR #39](https://github.com/bfraser/puppet-grafana/pull/39) Ability to ensure a specific package version is installed when using the 'repo' install method

**Fixes**
- [Issue #37](https://github.com/bfraser/puppet-grafana/issues/37) Archive install method: check if user and service are already defined before attempting to define them
- [Issue #42](https://github.com/bfraser/puppet-grafana/issues/42) Package versioning for RPM / yum systems
- [Issue #45](https://github.com/bfraser/puppet-grafana/issues/45) Fix resource dependency issues when ```manage_package_repo``` is false

**Behind The Scenes**
- Use 40 character GPG key ID for packagecloud apt repository

## 2.0.2 (2015-04-30)

**Enhancements**
- Support for Grafana 2.0. Users of Grafana 1.x should stick to version 1.x of the Puppet module
- Support 'archive', 'docker' and 'package' install methods
- Ability to supply a hash of parameters to the Docker container when using 'docker' install method
- [PR #24](https://github.com/bfraser/puppet-grafana/pull/24) Ability to configure Grafana using configuration hash parameter ```cfg```

**Behind The Scenes**
- Update module operatingsystem support, tags, Puppet requirements
- Tests for 'archive' and 'package' install methods

## 1.0.1 (2015-02-27)

**Enhancements**
- New parameter for Grafana admin password

**Fixes**
- Package install method now makes use of install_dir for config.js path

**Behind The Scenes**
- Add archive module to .fixtures.yml
- Unquote booleans to make lint happy
- Fix license identifier and unbounded dependencies in module metadata
- Allow Travis to fail on Ruby 1.8.7
- More Puppet versions are tested by Travis

## 1.0.0 (2014-12-16)

**Enhancements**
- Add max_search_results parameter
- Install Grafana 1.9.0 by default

**Documentation**
- Add download_url and install_method parameters to README

**Behind The Scenes**
- [Issue #6](https://github.com/bfraser/puppet-grafana/issues/6) Replace gini/archive dependency with camptocamp/archive
- Addition of CHANGELOG
- Style fixes
- Removal of vagrant-wrapper gem
- Fancy badges for build status

## 0.2.2 (2014-10-27)

**Enhancements**
- Add default_route parameter to manage start dashboard

**Fixes**
- Symlink behavior

**Behind The Scenes**
- [Issue #9](https://github.com/bfraser/puppet-grafana/issues/9) Remove stdlib inclusion from manifest

## 0.2.1 (2014-10-14)

**Enhancements**
- Support for multiple datasources
- Install Grafana 1.8.1 by default

**Behind The Scenes**
- Added RSpec tests
- Add stdlib as a module dependency
- Add operating system compatibility

## 0.1.3 (2014-07-03)

**Enhancements**
- Added support for InfluxDB

## 0.1.2 (2014-06-30)

First release on the Puppet Forge


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
