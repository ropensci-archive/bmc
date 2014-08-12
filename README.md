bmc
---------

[![Build status](https://ci.appveyor.com/api/projects/status/fitnci67m76iy0bg/branch/master)](https://ci.appveyor.com/project/sckott/bmc/branch/master)

**An R interface to BMC search API and full text XML**

API DOCS: [http://www.biomedcentral.com/about/api](http://www.biomedcentral.com/about/api)

No API key is required to use the BMC API.

## Quick start

### Install

```coffee
install.packages("devtools")
library(devtools)
install_github("ropensci/bmc")
library(bmc)
```

### Search

```coffee
out <- bmc_search(terms = 'fire', limit=2)
out@results$entries[[1]]
```

```coffee
$arxId
[1] "1476-4598-13-48"

$blurbTitle
[1] ""

$blurbText
[1] ""

$imageUrl
[1] "/content/figures/1476-4598-13-48-toc.gif"

$articleUrl
[1] "/content/13/1/48"

$articleFullUrl
[1] "http://www.molecular-cancer.com/content/13/1/48"

$type
[1] "research"

$doi
[1] "10.1186/1476-4598-13-48"

$isOpenAccess
[1] "true"

... cutoff
```

The object returned from `bmc_search` is an object of class _bmc_. The default print gives back a list of length _N_, where each element has the contents for the article in question. We can inspect further elements of the _bmc_ object with the `@` symbol. We can get the _urls_ element...

```coffee
out@urls
```

```coffee
[1] "http://www.molecular-cancer.com/content/13/1/48" "http://www.malariajournal.com/content/13/1/82"
```

...which has the urls you can use to go the paper in a browser

```coffee
browseURL(out@urls[1])
```

_which opens the paper in your default browser_

We can also inspect the _ids_ element, which has a list equal to the number you requested, where each element is of length 2, with a _arxId_, and a _url_. These two are used to construct the download url if you use `bmc_xml`.

```coffee
out@ids
```

```coffee
[[1]]
[[1]]$arxId
[1] "1476-4598-13-48"

[[1]]$url
[1] "http://www.molecular-cancer.com/content/13/1/48"


[[2]]
[[2]]$arxId
[1] "1475-2875-13-82"

[[2]]$url
[1] "http://www.malariajournal.com/content/13/1/82"
```

### Get full text XML

You can either pass in a url to the `uris` parameter in the `bmc_xml` function, or pass in the output of the `bmc_search` function to `bmc_xml` using the first parameter `obj`. First, passing in a url:

```coffee
uri <- 'http://www.biomedcentral.com/content/download/xml/1471-2393-14-71.xml'
bmc_xml(uris=uri)
```

```coffee
<?xml version="1.0"?>
<!DOCTYPE art SYSTEM "http://www.biomedcentral.com/xml/article.dtd">
<art>
  <ui>1471-2393-14-71</ui>
  <ji>1471-2393</ji>
  <fm>
    <dochead>Research article</dochead>
    <bibl>
      <title>
        <p>Physical violence during pregnancy and pregnancy outcomes in Ghana</p>
      </title>
      <aug>
        <au id="A1">
          <snm>Pool</snm>
          <mnm>Sharon</mnm>
          <fnm>Michelle</fnm>
          <insr iid="I1"/>
          <email>michelle.s.pool@gmail.com</email>
        </au>

...cutoff
```

Now the output from `bmc_search`

```coffee
out <- bmc_search(terms = 'science', limit=5)
dat <- bmc_xml(out)
length(dat)
```

```coffee
[1] 5
```

Remove elements that had no XML content.

```coffee
library(plyr)
dat <- compact(dat)
length(dat)
```

```coffee
[1] 1
```

Inspect the xml

```coffee
dat
```

```coffee
<?xml version="1.0"?>
<!DOCTYPE art SYSTEM "http://www.biomedcentral.com/xml/article.dtd">
<art>
  <ui>2051-1426-2-S2-P43</ui>
  <ji>2051-1426</ji>
  <fm>
    <dochead>Poster presentation</dochead>
    <bibl>
      <title>
        <p>P69. Targeting naturally presented, leukemia-derived HLA ligands with TCR-transgenic T cells for the treatment of therapy refractory leukemias</p>
      </title>
      <aug>
        <au ca="yes" id="A1">
          <snm>Richard</snm>
          <fnm>K</fnm>
          <insr iid="I1"/>
        </au>
        <au id="A2">
          <snm>Schober</snm>
          <fnm>S</fnm>
          <insr iid="I1"/>
        </au>

...cutoff
```

### Parse and search XML

Once you have XML content, you can go to work with e.g., xpath.

```coffee
uri <- 'http://www.biomedcentral.com/content/download/xml/1471-2393-14-71.xml'
xml <- bmc_xml(uris=uri)
library(XML)
xpathApply(xml[[1]], "//abs", xmlValue)
```

```coffee
[[1]]
[1] "AbstractBackgroundIn pregnancy, violence can have serious health consequences that could affect both mother and child. In Ghana there are limited data on this subject. We sought to assess the relationship between physical violence during pregnancy and pregnancy outcomes (early pregnancy loss, perinatal mortality and neonatal mortality) in Ghana.MethodThe 2008 Ghana Demographic and Health Survey data were used. For the domestic violence module, 2563 women were approached of whom 2442 women completed the module. After excluding missing values and applying the weight factor, 1745 women remained. Logistic regression analysis was performed to assess the relationship between physical violence in pregnancy and adverse pregnancy outcomes with adjustments for potential confounders.ResultsAbout five percent of the women experienced violence during their pregnancy. Physical violence in pregnancy was positively associated with perinatal mortality and neonatal mortality, but not with early pregnancy loss. The differences remained largely unchanged after adjustment for age, parity, education level, wealth status, marital status and place of residence: adjusted odds ratios were 2.32; 95% CI: 1.34-4.01 for perinatal mortality, 1.86; 95% CI: 1.05-3.30 for neonatal mortality and 1.16; 95% CI: 0.60-2.24 for early pregnancy loss.ConclusionOur findings suggest that violence during pregnancy is related to adverse pregnancy outcomes in Ghana. Major efforts are needed to tackle violence during pregnancy. This can be achieved through measures that are directed towards the right target groups. Measures should include education, empowerment and improving socio-economic status of women."
```
