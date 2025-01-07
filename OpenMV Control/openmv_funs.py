# COPY THIS FILE TO THE OPENMV STORAGE
#=================================================================================================
def str_to_literal(value_str):
    """Safely converts a string to a literal (tuple, list, int, float, str, bool, None)."""
    value_str = value_str.strip()
    if value_str.startswith("(") and value_str.endswith(")"):
        try:
            # Attempt to parse as a tuple
            return tuple(str_to_literal(x.strip()) for x in value_str[1:-1].split(","))
        except (ValueError, TypeError):
            pass #if it's not a tuple, try other types
    elif value_str.startswith("[") and value_str.endswith("]"):
        try:
            # Attempt to parse as a list
            return [str_to_literal(x.strip()) for x in value_str[1:-1].split(",")]
        except (ValueError, TypeError):
            pass
    try:
        return int(value_str)
    except ValueError:
        pass
    try:
        return float(value_str)
    except ValueError:
        pass
    if value_str.lower() == "true":
        return True
    elif value_str.lower() == "false":
        return False
    elif value_str.lower() == "none":
        return None
    return value_str #if everything fails, return the string

def read_config_file(filename, default_config):
    """Reads configuration from a file, merging it with defaults.
       Handles tuples without using the ast module.
    """
    config = default_config.copy()
    try:
        with open(filename, "r") as f:
            for line in f:
                line = line.strip()
                if line and "=" in line:
                    key, value_str = line.split("=", 1)
                    key = key.strip()
                    value = str_to_literal(value_str) #use the custom function
                    config[key] = value
        print(f"Configuration read from {filename}")
    except OSError:
        print(f"Configuration file {filename} not found, using default config.")

    # Write the merged configuration back to the file
    try:
        with open(filename, "w") as f:
            for key, value in config.items():
                f.write(f"{key} = {repr(value)}\n")
        print(f"Configuration written to {filename}")
    except OSError as e:
        print(f"Error writing to file: {e}")

    return config
#=================================================================================================