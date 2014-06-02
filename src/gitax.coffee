require("termcolor").define
fs = require("fs")
ITERATION_NUM = 100
GI_PER_LINE = 1.6741
TI_PER_LINE = 0.8687
BYTE_PER_LINE = 58.03

# main
# gi : gi(int)
# gitaxfile: gi_tax_nucl.dmp from taxonomy database from ftp://ftp.ncbi.nih.gov/pub/taxonomy/
# returns: tax_id(int) if exists, else null
module.exports = (gi, gitaxfile, namesfile)->
  tax_id = getTaxId(gi, gitaxfile)
  return tax_id if namesfile is null or tax_id is null

  # taxonomy 
  names = getNames(tax_id, namesfile)
  return tax_id: tax_id, names: names

# gi to tax
getTaxId = (gi, gitaxfile)->
  filesize = fs.statSync(gitaxfile).size
  fd = fs.openSync gitaxfile, "r"
  itr = 0
  left = 0
  right = filesize
  resultGi = 0
  tax_id = null
  estimatedByte = estimateByteFromGi(gi, GI_PER_LINE)

  # binary search
  until resultGi is gi or ++itr is ITERATION_NUM
    [resultGi, tax_id] = getGiFromByte(estimatedByte, gi, fd)
    if resultGi > gi
      right = estimatedByte
    else
      left = estimatedByte
    estimatedByte = Math.floor((left + right)/2)
  fs.closeSync fd

  return if itr is 100 then null else tax_id


# tax_id to tax_names
getNames = (tax_id, namesfile)->

  filesize = fs.statSync(namesfile).size
  fd = fs.openSync namesfile, "r" # file descriptor
  itr = 0
  left = 0
  right = filesize
  estimatedByte = BYTE_PER_LINE * (tax_id)/TI_PER_LINE
  resultTi = 0

  linelen = 4 * (BYTE_PER_LINE) # bytes to buffer. Allows enough bytes

  # binary search
  until (resultTi is tax_id) or ++itr is ITERATION_NUM
    buffer = new Buffer(linelen)
    fs.readSync fd, buffer, 0, linelen, estimatedByte
    line = buffer.toString().split("\n")[1]
    resultTi = Number line.split("|").map((v)-> v.trim()) .shift()

    if resultTi > tax_id
      right = estimatedByte
    else
      left = estimatedByte
    estimatedByte = Math.floor((left + right)/2)
  
  if itr is 100
    fs.closeSync fd
    return null

  buffer = new Buffer(linelen * 6)
  fs.readSync fd, buffer, 0, linelen*6, estimatedByte - linelen*3
  lines = buffer.toString().split("\n")
  names = []
  for line in lines
    [resultTi, name, uniq_name, name_class] = line.split("|").map (v)-> v.trim()
    resultTi = Number resultTi
    if resultTi is tax_id
      names.push name: name, uniq_name: uniq_name, name_class: name_class

  fs.closeSync fd
  return if names.length is 0 then null else names

# 10^m
pow10 = (m)-> Math.pow 10, m

estimateByteFromGi = (gi, R)->
  byte = 0
  magni = gi.toString().length
  byte += (i + 6) * (pow10(i) - pow10(i-1)) / R for i in [1..magni-1]
  byte += (magni + 6) * (gi - pow10(magni-1)) / R
  return parseInt byte
  
getGiFromByte = (byte, gi, fd)->
  linelen = 3 * (gi.toString().length + 6) # bytes to buffer. Allows enough bytes
  buffer = new Buffer(linelen)
  fs.readSync fd, buffer, 0, linelen, byte
  line = buffer.toString().split("\n")[1]
  return line.split("\t").map Number



getTiFromByte = (byte, fd)->
  linelen = 3 * (gi.toString().length + 6) # bytes to buffer. Allows enough bytes
  buffer = new Buffer(linelen)
  fs.readSync fd, buffer, 0, linelen, byte
  line = buffer.toString().split("\n")[1]
  return line.split("\t").map Number



