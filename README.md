# RSysrev
An R client for sysrev.com.  

## Install and get annotations from public projects

```{r}
devtools::install_github("sysrev/RSysrev")
df <- RSysrev::getAnnotations(3144)
View(df)
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
