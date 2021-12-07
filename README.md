# RSysrev 

A simple client for sysrev.com/graphql to:

1. get project [articles](#get-article-data), [definitions](#get-label-definitions) and [reviews](#get-label-answers).
2. automate reviews `?sysrev.setLabelAnswer`

## Get Started
1. Install with `devtools::install_github("sysrev/RSysrev")`.  
2. A Sysrev premium token (API key) is required. Find it at your sysrev profile page.  
3. RSysrev looks for your token at `keyring::key_get('sysrev.token')`.

## Get label definitions
In the below examples we use some public projects.  
This code will not work for you unless you clone these projects and replace the 
project identifier (3144 below) with your own project identifier. 
RSysrev calls will only work on projects for which your token is an administrator. 

```
df <- sysrev.getLabelDefinitions(3144)
```
| project.id|lbl.id                               |lbl.name   |lbl.question               | lbl.ordering|lbl.required |lbl.type    |lbl.consensus |lbl.enabled |
|----------:|:------------------------------------|:----------|:--------------------------|------------:|:------------|:-----------|:-------------|:-----------|
|       3144|1b3b792e... |Include    |Include this article?      |            0|TRUE         |boolean     |TRUE          |TRUE        |
|       3144|da66020a... |Study Type |What type of study? |            1|TRUE         |categorical |FALSE         |TRUE        |

## Get label answers
```
df <- sysrev.getLabelAnswers(3144)
```
| project.id| article.id|article.enabled |lbl.id                               |lbl.name |lbl.type |answer.created      |answer.updated      |answer.resolve |answer.confirmed    |answer.consensus | reviewer.id|reviewer.name |answer |
|----------:|----------:|:---------------|:------------------------------------|:--------|:---------------------|:--------|:-------------------|:-------------------|:--------------|:-------------------|:----------------|-----------:|:-------------|:------|
|       3144|    1522635|TRUE            |1b3b792e... |Include  |boolean  |2018-08-17 22:31:30 |2018-08-17 22:31:30 |NA             |2018-08-17 22:31:30 |TRUE             |         120|corey.gray    |false  |
|       3144|    1522710|TRUE            |1b3b792e... |Include  |boolean  |2018-09-04 23:52:53 |2018-09-04 23:52:53 |NA             |2018-09-04 23:52:53 |TRUE             |         184|andy.kelsall  |false  |
|       3144|    1522758|TRUE            |1b3b792e... |Include  |boolean  |2018-08-29 22:35:06 |2018-08-29 22:35:06 |NA             |2018-08-29 22:35:06 |TRUE             |         174|zekeg3        |true   |

## Get group label answers
The `getGroupLabelAnswers` function returns a list of dataframes named by their group label name.
```
grouplabels <- sysrev.getGroupLabelAnswers(<your project id>)
```


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
Once you have uploaded documents to a sysrev project, you can get the article identifiers, enabled status, and datasource.insilica.co identifiers with `sysrev.getArticles(project_id,token)`

```{r}
df <- sysrev.getArticles(3144)
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
