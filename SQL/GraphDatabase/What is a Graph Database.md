# Lezione di database NoSQL sui Database a grafo

In questa lezione vedremo cos'è un database a grafo, quali sono i suoi vantaggi e come usarlo con alcuni esempi pratici.

## Cos'è un database a grafo?

Un database a grafo è una tipologia di database che utilizza nodi e archi per rappresentare e archiviare l'informazione. La rappresentazione dei dati mediante grafi offre un'alternativa al modello relazionale che fa uso di tabelle, ai database orientati al documento, o altri, come i sistemi ad archivi strutturati basati su colonne o su cesti non interpretati di dati[^1^][1].

I nodi rappresentano le entità del dominio dei dati, come persone, organizzazioni, prodotti, ecc. Gli archi rappresentano le relazioni tra le entità, come amicizia, appartenenza, acquisto, ecc. A entrambi i nodi e gli archi possono essere associate delle proprietà, che sono coppie chiave-valore che descrivono ulteriormente le caratteristiche delle entità o delle relazioni.

## Quali sono i vantaggi di un database a grafo?

I database a grafo presentano alcuni vantaggi rispetto ai database tradizionali, soprattutto quando si tratta di gestire dati complessi e interconnessi. Alcuni di questi vantaggi sono:

- Velocità: i database a grafo sono in grado di eseguire query sulle relazioni tra i dati in modo molto rapido ed efficiente, grazie al fatto che le relazioni sono già memorizzate nel database e non devono essere calcolate al momento della query.
- Flessibilità: i database a grafo non richiedono uno schema fisso e rigido per definire la struttura dei dati, ma si adattano facilmente ai cambiamenti dei requisiti e dei dati stessi. Inoltre, i database a grafo permettono di modellare i dati in modo più naturale e intuitivo, riflettendo la realtà del dominio dei dati.
- Scalabilità: i database a grafo sono in grado di gestire grandi quantità di dati e di relazioni, distribuendoli su più nodi di un cluster e garantendo alte prestazioni e affidabilità.

## Come usare un database a grafo?

Per usare un database a grafo, bisogna scegliere un sistema di gestione dei database a grafo (Graph Database Management System, GDBMS), che è un software che permette di creare, manipolare e interrogare i dati memorizzati in un database a grafo. Esistono diversi GDBMS sul mercato, che si differenziano per le caratteristiche, le funzionalità e i linguaggi di interrogazione che offrono. Alcuni esempi di GDBMS sono:

- Neo4j: è uno dei GDBMS più popolari e usati, che implementa il modello dei dati del grafo di proprietà e usa il linguaggio Cypher per le query.
- Amazon Neptune: è un GDBMS offerto da Amazon Web Services, che supporta sia il modello RDF che il modello dei dati del grafo di proprietà e usa i linguaggi SPARQL e Gremlin per le query.
- Microsoft SQL Server: è un sistema di gestione dei database relazionali che offre anche la possibilità di creare e gestire database a grafo usando il linguaggio Transact-SQL.

In questa lezione useremo Neo4j come GDBMS di riferimento e Cypher come linguaggio di interrogazione. Per seguire la lezione, ti consigliamo di scaricare e installare Neo4j Desktop sul tuo computer e di creare un nuovo progetto con un database a grafo vuoto.

## Esempi pratici

In questa sezione vedremo alcuni esempi pratici di come usare un database a grafo con Neo4j e Cypher. Per ogni esempio, ti mostreremo il codice da scrivere nella console di Neo4j e il risultato che otterrai.

### Creare nodi e archi

Per creare un nodo in Neo4j, usiamo la clausola CREATE seguita da una parentesi tonda con il nome del nodo (opzionale) e le sue proprietà (opzionali). Per esempio:

```cypher
// Creare un nodo con il nome "Alice" e la proprietà "name" uguale a "Alice"
CREATE (Alice {name: "Alice"})
