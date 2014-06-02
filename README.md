gitax
==========
gitax fetches taxonomy_id,names from given NCBI gi.

installation
----------------
```bash
$ npm install -g gitax
```

usage
-------------
command line
```bash
gi=1234567
tax_id=$(gitax $gi /path/to/gi_tax_nucl.dmp)
echo $tax_id
```

with taxonomy names
```bash
gi=1234567
gitax $gi /path/to/gi_tax_nucl.dmp --names /path/to/names.dmp
```


set default files
```bash
gitax_set /path/to/gi_tax_nucl.dmp --names /path/to/names.dmp

# run without gi_tax_nucl
gitax 1234567

# unset
gitax_set
```

JavaScript API
```js
gitax = require("gitax")
tax_id = gitax(1234567, "/path/to/gi_tax_nucl.dmp");
```

with taxonomy names
```js
gitax = require("gitax")
taxinfo = gitax(1234567, "/path/to/gi_tax_nucl.dmp", "/path/to/names.dmp");
console.log(taxinfo.tax_id); // taxonomy id
console.log(taxinfo.names); // taxonomy names // array of [name, uniq_name, name_class]
```

gi_tax_nucl.dmp?
------------------
a file which describes relations between gi and taxonomy_id

download one from ftp://ftp.ncbi.nih.gov/pub/taxonomy/

names.dmp?
------------------
a file which describes relations between gi and taxonomy_id

downloaded with gi_tax_nucl.dmp (from ftp://ftp.ncbi.nih.gov/pub/taxonomy/)


```bash
wget -r ftp://ftp.ncbi.nih.gov/pub/taxonomy/
```
