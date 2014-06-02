showUsage = ->
  console.error """

  [USAGE]
  setting defualt files:
  \tgitax_set <gi_tax_nucl.dmp> [--names names.dmp]
  
  unset :
  \tgitax_set
"""

exports.run = ->
  # argument definition
  try
    ap = require("argparser")
    .vals("names")
    .parse()
  catch e
    console.error "[ERROR]: #{e.message}"
    showUsage()
    process.exit(1)

  gi_tax_nucl= ap.arg(0) or null
  names = ap.opt("names") or null

  path = require('path')
  fs   = require('fs')
  file = path.join(path.dirname(fs.realpathSync(__filename)), '../.files.json')

  json = gi_tax_nucl: gi_tax_nucl, names: names
  console.log file

  fs.writeFileSync(file, JSON.stringify(json))

exports.run() if require.main is module

