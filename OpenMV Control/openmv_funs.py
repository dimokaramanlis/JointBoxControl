# COPY THIS FILE TO THE OPENMV STORAGE
#=================================================================================================

def get_default_config():
    default_config = {
        "sensor_window": (105,50,135,188),
        "sensor_brightness": 0,
        "transpose_first": True,
        "to_transpose": True,
        "to_hmirror":   True,
        "to_vflip":   False,
        "mouse_thres_int": (0, 65),
        "region_M1": (0,   3,  188, 64),
        "platform_cent_M1": (84,   54),
        "region_M2": (0 , 67,  188, 64),
        "platform_cent_M2": (0,  79),
        "radius_M1_M2": (8 ,8),
        "angle_requirement_deg": 45,
        "history_alpha_x": 0.85,
        "history_alpha_y": 0.99,
        "draw_M1": (0, 0, 0),
        "draw_M2": (100,100,100)
    }
    return default_config


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

def read_config_file(filename):
    """Reads configuration from a file, merging it with defaults.
       Handles tuples without using the ast module.
    """
    default_config = get_default_config()
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