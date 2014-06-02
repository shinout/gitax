module.exports = (args...)->
  process.stdout.write args.join(" ")
  process.stdout.write "\n"

module.exports.e = (args...)->
  process.stderr.write args.join(" ")
  process.stderr.write "\n"
