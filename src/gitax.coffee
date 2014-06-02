fs = require("fs")
ITERATION_NUM = 100
GI_PER_LINE = 1.6741

# main
# gitaxfile: gi_tax_nucl.dmp from taxonomy database from ftp://ftp.ncbi.nih.gov/pub/taxonomy/
# gi : gi(int)
# returns: tax_id(int) if exists, else null
module.export = (gitaxfile, gi)->
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

  return if itr is 100 then null else tax_id

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
  \gitax <gi_tax_nucl.dmp> gi

  \tgi_tax_nucl.dmp: gi_tax data from ftp://ftp.ncbi.nih.gov/pub/taxonomy/
  \t result: tax_id to stdout
"""

exports.run = ->
  # argument definition
  try
    ap = require("argparser")
    .files(0)
    .arglen(2,2)
    .nums(1)
    .parse()
  catch e
    console.error "[ERROR]: #{e.message}"
    showUsage()
    process.exit(1)

  file = ap.arg(0)
  gi = ap.arg(1)
  tax_id = module.export(file, gi)
  if tax_id? then console.log tax_id else console.error "not found"

exports.run() if require.main is module
