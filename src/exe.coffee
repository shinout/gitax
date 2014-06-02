#!/usr/bin/env node

path = require('path')
fs   = require('fs')
lib  = path.join(path.dirname(fs.realpathSync(__filename)), '../lib')

gitax = require(lib + '/gitax.js')

# show usage for console
showUsage = ->
  console.error """

  [USAGE]
  \tgitax gi <gi_tax_nucl.dmp> gi [--names names.dmp]

  \tgi: NCBI gi(integer)
  \tgi_tax_nucl.dmp: gi_tax data from ftp://ftp.ncbi.nih.gov/pub/taxonomy/
  \t result: tax_id to stdout
  \tnames.dmp: taxonomy_id-name data from ftp://ftp.ncbi.nih.gov/pub/taxonomy/

  setting default files
    gitax_set <gi_tax_nucl.dmp> gi [--names names.dmp]
"""

# argument definition
try
  ap = require("argparser")
  .vals("names")
  .nums(0)
  .parse()

  try
    json = require(__dirname + "/../.files.json")
  catch e
    json = {}

  gi = ap.arg(0)
  file = ap.arg(1) or json.gi_tax_nucl
  namesfile = ap.opt("names") or json.names

  throw message: "file : #{file},  no such file." unless fs.existsSync(file)
  throw message: "namesfile : #{namesfile},  no such file." if namesfile and not fs.existsSync(namesfile)

catch e
  console.error "[ERROR]: #{e.message}"
  showUsage()
  process.exit(1)

tax_id = gitax(gi, file, namesfile)

return console.error "not found" unless tax_id?

return console.log tax_id unless namesfile or tax_id.names is null

for name in tax_id.names
  console.log [tax_id.tax_id, name.name or "*", name.uniq_name or "*", name.name_class or "*"].join("\t")
