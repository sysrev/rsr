# RSysrev
An R client for sysrev.com.  This simple client is built on [sysrev.com/graphql](https://sysrev.com/graphql) which is a graphql endpoint.  You can view the graphql schema by opening sysrev.com/graphql in a graphql IDE like [insomnia](https://insomnia.rest/graphql/).

The tool can be used to:
1. [Get your API token](#get-your-api-token)
2. [Get label definitions from projects](#get-label-definitions)
3. [Get all reviewer answers from a project](#get-label-answers)
	1. [Get basic label answers](#get-label-answers)
	2. [Get group label answers](#get-group-label-answers)
5. [Get all reviewer annotations from a project](#get-annotations)
6. [Get article data](#get-article-data)
	1. [Get sysrev article data](#get-sysrev-article-data)
	2. [Get datasource RIS data](#get-datasource-RIS-data)

## Installation
Install with `devtools::install_github("sysrev/RSysrev")`

## <a href="#get-your-api-token">Get your api token</a>
You need an API token to use RSysrev.  This API token is used to authenticate access to sysrev projects.
To get an API token, you must have a pro or team pro account on sysrev.com.  See sysrev.com/pricing.

To get your token log in to sysrev.com click on your profile and go to settings. Copy your token.

You can set a default token value for function calls by using
```
.token <- "some token" # token is now provided implicitly to function calls
RSysrev::sysrev.getLabelDefinitions(<project-id>) # works because the token argument default is set to `.token`
```

## Get label definitions
In the below examples we use some public projects.  
This code will not work for you unless you clone these projects and replace the 
project identifier (3144 below) with your own project identifier. 
RSysrev calls will only work on projects for which your token is an administrator. 

```
df <- RSysrev::sysrev.getLabelDefinitions(3144)
```
| project.id|lbl.id                               |lbl.name   |lbl.question               | lbl.ordering|lbl.required |lbl.type    |lbl.consensus |lbl.enabled |
|----------:|:------------------------------------|:----------|:--------------------------|------------:|:------------|:-----------|:-------------|:-----------|
|       3144|1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include    |Include this article?      |            0|TRUE         |boolean     |TRUE          |TRUE        |
|       3144|da66020a-058f-44b4-9b93-fdd043795991 |Study Type |What type of study was it? |            1|TRUE         |categorical |FALSE         |TRUE        |

## Get label answers
```
df <- RSysrev::sysrev.getLabelAnswers(3144)
```
| project.id| article.id|article.enabled |lbl.id                               |lbl.name |lbl.question          |lbl.type |answer.created      |answer.updated      |answer.resolve |answer.confirmed    |answer.consensus | reviewer.id|reviewer.name |answer |
|----------:|----------:|:---------------|:------------------------------------|:--------|:---------------------|:--------|:-------------------|:-------------------|:--------------|:-------------------|:----------------|-----------:|:-------------|:------|
|       3144|    1522635|TRUE            |1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include  |Include this article? |boolean  |2018-08-17 22:31:30 |2018-08-17 22:31:30 |NA             |2018-08-17 22:31:30 |TRUE             |         120|corey.gray    |false  |
|       3144|    1522710|TRUE            |1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include  |Include this article? |boolean  |2018-09-04 23:52:53 |2018-09-04 23:52:53 |NA             |2018-09-04 23:52:53 |TRUE             |         184|andy.kelsall  |false  |
|       3144|    1522758|TRUE            |1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include  |Include this article? |boolean  |2018-08-29 22:35:06 |2018-08-29 22:35:06 |NA             |2018-08-29 22:35:06 |TRUE             |         174|zekeg3        |true   |

## Get group label answers
The `getGroupLabelAnswers` function returns a list of dataframes named by their group label name.
```
grouplabels <- RSysrev::sysrev.getGroupLabelAnswers(<your project id>)
```
## Get annotations

```{r}
devtools::install_github("sysrev/RSysrev")
df <- RSysrev::sysrev.getAnnotations(3144)
```

This results in the below table:

| selection | annotation | semantic_class | external_id | sysrev_id | text                              | start | end | datasource |
|-----------|------------|----------------|-------------|-----------|-----------------------------------|-------|-----|------------|
| α-KGDH    | α-KGDH     | gene           | 29211711    | 1524023   | Histone modifications, such as... | 280   | 286 | pubmed     |
| KAT2A     | KAT2A      | gene           | 29211711    | 1524023   | Histone modifications, such as... | 280   | 286 | pubmed     |
| TNF-α     | TNF-α      | gene           | 29274398    | 1523665   | OBJECTIVES: Several articles...   | 407   | 411 | pubmed     |

Each row corresponds to a single article annotation.  There may be multiple annotations per article.  

1. **selection**  = text selected by reviewer
2. **annotation** = value input by reviewer
3. **semantic_class** = semantic_class selected by reviewer for annotation
4. **external_id**    = sysrev imports articles from external datasources, this is the external datasource article id.  
5. **sysrev_id**      = sysrev assigns an identifier to every imported article. This is the sysrev article id.
6. **text**           = reference text for annotation
7. **start**          = number of characters offset until start of selected text
8. **end**            = number of characters offset until end of selected text
9. **datasource**     = the external data source that created this article 

## Get article data
Every document reviewed on sysrev.com comes from a datasource.
Datasources include pubmed, RIS files, endnote files, trials from clinicaltrials.gov and more. 
These datasources can be created, read, updated and deleted at datasource.insilica.co. 
The login you use at sysrev.com will also work at datasource.insilica.co, as will your sysrev token. 

Each article on sysrev has 3 identifiers:
1. **article.id** A numeric identifier that can be accessed at sysrev.com. For example: sysrev.com/p/3144/article/1522635
2. **article.datasource.id** A numeric identifier used at datasource.insilica.co for the same articel
3. **article.datasource.name** This is a name that identifies the kind of source an article belongs to eg. pubmed, RIS, etc.


### Get sysrev article data
Once you have uploaded documents to a sysrev project, you can get the article identifiers, enabled status, and datasource.insilica.co identifiers with `RSysrev::sysrev.getArticles(project_id,token)`

```{r}
df <- RSysrev::sysrev.getArticles(3144)
```

| project.id| article.id|article.enabled | article.datasource.id|article.datasource.name |
|----------:|----------:|:---------------|---------------------:|:-----------------------|
|       3144|    1522635|TRUE            |              29138264|pubmed                  |
|       3144|    1522710|TRUE            |              28867768|pubmed                  |
|       3144|    1522758|TRUE            |              29118119|pubmed                  |

1. **project.id:** The originating project.
2. **article.id:** The sysrev article identifier (see sysrev.com/p/3144/article/1522635).
3. **article.enabled:** true when the datasource containing an article is enabled (see sysrev.com/p/3144/add-articles).
4. **article.datasource.id:** The datasource.insilica.co identifier for an article
5. **article.datasource.name:** The name of the datasource at datasource.insilica.co 

### Get datasource Pubmed data
All sysrev article data comes from datasource.insilica.co. Datasource functions are namespaced under `datasource`. 

```{r}
srDF <- RSysrev::sysrev.getArticles(3144) # sysrev.com/p/3144 uses pubmed articles
dsDF <- RSysrev::datasource.getArticleData(srDF$article.datasource.id,"pubmed")
```

| datasource.id|abstract                       |authors                        |date       |keywords                       |primary_title                  |secondary_title                |updated                    |year |url                            |
|-------------:|:------------------------------|:------------------------------|:----------|:------------------------------|:------------------------------|:------------------------------|:--------------------------|:----|:------------------------------|
|      21458468|BACKGROUND/PURPOSE: The fla... |Rivera, WL.;Justo, CAC.;Rel... |2018-06-13 |Female sex worker (FSW);Phi... |Detection and molecular cha... |Journal of microbiology, im... |2020-02-10 23:20:27.147061 |2018 |/entity/82b20e78d98704841cd... |
|      24722414|MicroRNAs (miRNAs) are smal... |Xiao, M.;Li, J.;Li, W.;Wang... |2018-07-27 |Chromatin modification;enha... |MicroRNAs activate gene tra... |RNA biology                    |2020-02-10 23:20:27.147061 |2018 |/entity/b317327bf53803cbeb3... |
|      25354391|BACKGROUND: Candida albican... |Ou, TY.;Chang, FM.;Cheng, W... |2018-07-20 |Candida albicans;fluconazol... |Fluconazole induces rapid h... |Journal of microbiology, im... |2020-02-10 23:20:27.147061 |2018 |/entity/5f55dd594893ef5d1a3... |

A description of this schema is available at [datasource.insilica.co]()

### Get datasource RIS data

```{r}
srDF <- RSysrev::sysrev.getArticles(35446)
dsDF <- RSysrev::datasource.getArticleData(srDF$article.datasource.id,"RIS")
```

|A2 |AB                             |AN |AU                             |DA        |DO                            |DP        |EP  |ET |IS |J2                             |KW                             |L2 |LA |M3 |N1                             |PB |PY   |SN        |SP  |T2                             |T3 |TI                             |TY   |UR                             |VL |id    | datasource.id|
|:--|:------------------------------|:--|:------------------------------|:---------|:-----------------------------|:---------|:---|:--|:--|:------------------------------|:------------------------------|:--|:--|:--|:------------------------------|:--|:----|:---------|:---|:------------------------------|:--|:------------------------------|:----|:------------------------------|:--|:-----|-------------:|
|NA |Objective: Intentional reco... |NA |Carolan, Marsha;Onaga, Esth... |2011///   |NA                            |EBSCOhost |132 |NA |2  |Psychiatric Rehabilitation ... |Adult;Female;Male;Grounded ... |NA |NA |NA |<p>Accession Number: 104591... |NA |2011 |1095-158X |125 |Psychiatric Rehabilitation ... |NA |A Place to Be: The Role of ... |JOUR |http://ezaccess.libraries.p... |35 |45176 |         45176|
|NA |The article discusses resea... |NA |Eftimovska-Tashkovska, Juli... |2016/06// |10.1080/17542863.2015.1103277 |EBSCOhost |138 |NA |2  |International Journal of Cu... |Focus Groups;Mental Health;... |NA |NA |NA |<p>Accession Number: 114928... |NA |2016 |1754-2863 |127 |International Journal of Cu... |NA |A qualitative evaluation of... |JOUR |http://ezaccess.libraries.p... |9  |45177 |         45177|
|NA |Objective: This investigati... |NA |Fairman, Nathan;Irwin, Scott A |2013/06// |10.1017/S1478951513000096     |EBSCOhost |276 |NA |3  |Palliative & Supportive Care   |Female;Male;Suicide, Attemp... |NA |NA |NA |<p>Accession Number: 104084... |NA |2013 |1478-9515 |273 |Palliative & Supportive Care   |NA |A retrospective case series... |JOUR |http://ezaccess.libraries.p... |11 |45178 |         45178|

