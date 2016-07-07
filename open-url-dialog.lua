-- To the extent possible under law, the author(s) have dedicated all copyright
-- and related and neighboring rights to this software to the public domain
-- worldwide. This software is distributed without any warranty. See
-- <https://creativecommons.org/publicdomain/zero/1.0/> for a copy of the CC0
-- Public Domain Dedication, which applies to this software.

utils = require 'mp.utils'

function open_url_dialog()
	local was_ontop = mp.get_property_native("ontop")
	if was_ontop then mp.set_property_native("ontop", false) end
	local res = utils.subprocess({
		args = {'powershell', '-NoProfile', '-Command', [[& {
			Trap {
				Write-Error -ErrorRecord $_
				Exit 1
			}
			Add-Type -AssemblyName Microsoft.VisualBasic

			$u8 = [System.Text.Encoding]::UTF8
			$out = [Console]::OpenStandardOutput()

      $urlname = [Microsoft.VisualBasic.Interaction]::InputBox("Enter URL:", "Open a URL", "http[s]://")
      $u8urlname = $u8.GetBytes("$urlname`n")
      $out.Write($u8urlname, 0, $u8urlname.Length)

		}]]},
		cancellable = false,
	})
	if was_ontop then mp.set_property_native("ontop", true) end
	if (res.status ~= 0) then return end

  mp.commandv('loadfile', res.stdout)
end

mp.add_key_binding('ctrl+O', 'open-url-dialog', open_url_dialog)

