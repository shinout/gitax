fs = require("fs")
ITERATION_NUM = 100
GI_PER_LINE = 1.6741
TI_PER_LINE = 0.8687
BYTE_PER_LINE = 58.03

# main
# gi : gi(int)
# gitaxfile: gi_tax_nucl.dmp from taxonomy database from ftp://ftp.ncbi.nih.gov/pub/taxonomy/
# returns: tax_id(int) if exists, else null
module.export = (gi, gitaxfile, namesfile)->
  fd = fs.openSync gitaxfile, "r" # file descriptor
  tax_id = null # taxonomy id
  resultGi = 0  # searched gi
  bytes = 0     # byte offset
  linelen = 2 * (gi.toString().length + 6) # bytes to buffer. Allows enough bytes
  itr = 0 # iteration num

  until (resultGi is gi) or ++itr is ITERATION_NUM
    bytes += deltaBytes(gi, resultGi, GI_PER_LINE)
    buffer = new Buffer(linelen)
    fs.readSync fd, buffer, 0, linelen, bytes
    line = buffer.toString().split("\n").reduce (line, mxline)-> if !mxline or line.length >= mxline.length then line else mxline
    [resultGi, tax_id] = line.split("\t").map Number

  fs.closeSync fd
  return null if itr is 100

  return tax_id unless namesfile

  # taxonomy 
  fd = fs.openSync namesfile, "r"
  tax_names = [] # taxonomy names
  resultTi = 0  # searched tax_id
  bytes = 0     # byte offset
  linelen = 4 * (BYTE_PER_LINE) # bytes to buffer. Allows enough bytes
  itr = 0 # iteration num

  until (resultTi is tax_id) or ++itr is ITERATION_NUM
    bytes += BYTE_PER_LINE * (tax_id - resultTi)/TI_PER_LINE
    buffer = new Buffer(linelen)
    fs.readSync fd, buffer, 0, linelen, bytes
    line = buffer.toString().split("\n").reduce (line, mxline)-> if !mxline or line.length >= mxline.length then line else mxline

    [resultTi, name, uniq_name, name_class] = line.split("|").map (v)-> v.trim()
    resultTi = Number resultTi
  
  if itr is 100
    fs.closeSync fd
    return tax_id: tax_id, names: null

  buffer = new Buffer(linelen * 6)
  fs.readSync fd, buffer, 0, linelen*6, bytes - linelen*3
  lines = buffer.toString().split("\n")
  names = []
  for line in lines
    [resultTi, name, uniq_name, name_class] = line.split("|").map (v)-> v.trim()
    resultTi = Number resultTi
    if resultTi is tax_id
      names.push name: name, uniq_name: uniq_name, name_class: name_class

  fs.closeSync fd
  return tax_id: tax_id, names: if names.length is 0 then null else names

# 10^m
pow10 = (m)-> Math.pow 10, m

# calc byte difference
deltaBytes = (a, b, r)->
  A = Math.max(a,b)
  B = Math.min(a,b)
  R = r
  rBytes = 0

  AMagni = A.toString().length
  BMagni = B.toString().length
  if AMagni > BMagni
    rBytes += (i + 6) * (pow10(i) - pow10(i-1)) / R for i in [BMagni..AMagni-1]
  rBytes += (AMagni + 6) * (A - Math.max(B, pow10(AMagni-1)))
  rBytes = -rBytes if a < b
  parseInt rBytes

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

exports.run = ->
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

    console.log json
    gi = ap.arg(0)
    file = ap.arg(1) or json.gi_tax_nucl
    namesfile = ap.opt("names") or json.names

    throw message: "file : #{file},  no such file." unless fs.existsSync(file)
    throw message: "namesfile : #{namesfile},  no such file." if namesfile and not fs.existsSync(namesfile)

  catch e
    console.error "[ERROR]: #{e.message}"
    showUsage()
    process.exit(1)

  tax_id = module.export(gi, file, namesfile)

  return console.error "not found" unless tax_id?

  return console.log tax_id unless namesfile or tax_id.names is null

  for name in tax_id.names
    console.log [tax_id.tax_id, name.name or "*", name.uniq_name or "*", name.name_class or "*"].join("\t")

exports.run() if require.main is module
