#!/bin/sh

package_name=rivendell
package_version="$(dpkg -s rivendell | grep -i version)"
if [ $(apt list --upgradable 2>/dev/null | grep $package_name) ]; then echo "${package_name} ${package_version} is avaliable to update"; else echo "${package_name} ${package_version}"; fi
