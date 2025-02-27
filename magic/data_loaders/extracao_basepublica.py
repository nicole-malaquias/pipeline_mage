from mage_ai.data_preparation.decorators import data_loader, test
from pyspark.sql import SparkSession


@data_loader
def load_data_from_big_query(*args, **kwargs):
    """
    Carrega dados da tabela `basedosdados.br_inep_saeb.aluno_ef_9ano` no BigQuery usando PySpark.
    Certifique-se de que suas credenciais do Google Cloud estão configuradas corretamente.
    """
    spark = (
        SparkSession.builder
        .appName("MageAI-Spark-BigQuery")
        .master("spark://spark-master:7077") 
        .config("spark.driver.memory", "1g")
        .config("spark.executor.memory", "1g")
        .config("spark.sql.shuffle.partitions", "4")
        .config(
            "spark.jars.packages",
            "com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.30.0"
        )
        .getOrCreate()
    )

    # Definir credenciais do Google Cloud
    credentials_path = "/home/src/keys/gcp_credentials.json"

    # Carregar dados do BigQuery via PySpark
    df = spark.read\
        .format("bigquery")\
        .option("credentialsFile", credentials_path)\
        .option("table", "basedosdados.br_inep_saeb.aluno_ef_9ano")\
        .load()

    df.show(5)  # Exibir amostra

    return df

@test
def test_output(output, *args) -> None:
    """
    Testa se os dados foram carregados corretamente.
    """
    assert output is not None, 'A saída está vazia'
    assert output.count() > 0, 'A consulta retornou um DataFrame vazio'
