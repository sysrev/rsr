# RSysrev
An R client for sysrev.com.  This simple client is built on [sysrev.com/graphql](https://sysrev.com/graphql) which is a graphql endpoint.  You can view the graphql schema by opening sysrev.com/graphql in a graphql IDE like [insomnia](https://insomnia.rest/graphql/).

The tool can be used to:
1. [Get your API token](#get-your-api-token)
2. [Get label definitions from projects](#get-label-definitions)
3. [Get all reviewer answers from a project](#get-label-answers)
4. [Get all reviewer annotations from a project](#get-annotations-from-public-projects)

## Installation
Install with `devtools::install_github("sysrev/RSysrev")`

## <a href="#get-your-api-token">Get your api token</a>
You need an API token to use RSysrev.  This API token is used to authenticate access to sysrev projects.
To get an API token, you must have a pro or team pro account on sysrev.com.  See sysrev.com/pricing.

```
# method 1 - get token by providing your sysrev.com credentials
token <- getAPIToken(<sysrev login email>,<sysrev.com password>)

# method 2 - login through a text interface, which will ask for email and password.
token <- loginAPIToken() 
```

## Get label definitions
```
df <- RSysrev::getLabelDefinitions(3144,<your token>)
```
| project.id|lbl.id                               |lbl.name   |lbl.question               | lbl.ordering|lbl.required |lbl.type    |lbl.consensus |lbl.enabled |
|----------:|:------------------------------------|:----------|:--------------------------|------------:|:------------|:-----------|:-------------|:-----------|
|       3144|1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include    |Include this article?      |            0|TRUE         |boolean     |TRUE          |TRUE        |
|       3144|da66020a-058f-44b4-9b93-fdd043795991 |Study Type |What type of study was it? |            1|TRUE         |categorical |FALSE         |TRUE        |

## Get label answers
```
df <- RSysrev::getLabelAnswers(project-id,token)
```
| project.id| article.id|article.enabled |lbl.id                               |lbl.name |lbl.question          |lbl.type |answer.created      |answer.updated      |answer.resolve |answer.confirmed    |answer.consensus | reviewer.id|reviewer.name |answer |
|----------:|----------:|:---------------|:------------------------------------|:--------|:---------------------|:--------|:-------------------|:-------------------|:--------------|:-------------------|:----------------|-----------:|:-------------|:------|
|       3144|    1522635|TRUE            |1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include  |Include this article? |boolean  |2018-08-17 22:31:30 |2018-08-17 22:31:30 |NA             |2018-08-17 22:31:30 |TRUE             |         120|corey.gray    |false  |
|       3144|    1522710|TRUE            |1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include  |Include this article? |boolean  |2018-09-04 23:52:53 |2018-09-04 23:52:53 |NA             |2018-09-04 23:52:53 |TRUE             |         184|andy.kelsall  |false  |
|       3144|    1522758|TRUE            |1b3b792e-7233-459b-b211-0b822ca0f6e5 |Include  |Include this article? |boolean  |2018-08-29 22:35:06 |2018-08-29 22:35:06 |NA             |2018-08-29 22:35:06 |TRUE             |         174|zekeg3        |true   |

## Get annotations from public projects

```{r}
devtools::install_github("sysrev/RSysrev")
df <- RSysrev::getAnnotations(3144)
head(df)
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
