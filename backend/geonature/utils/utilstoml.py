
from pathlib import Path
import toml

from geonature.utils.errors import ConfigError


def load_and_validate_toml(toml_file, config_schema):
    '''
        Fonction qui charge un fichier toml
         et le valide avec un Schema marshmallow
    '''
    if Path(toml_file).is_file():
        toml_config = toml.load(str(toml_file))
        configs_py, configerrors = config_schema().load(toml_config)
        if configerrors:
            raise ConfigError(toml_file, configerrors)
        return configs_py
    else:
        raise FileNotFoundError(toml_file)