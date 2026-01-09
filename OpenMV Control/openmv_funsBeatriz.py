# Beatriz Task
#=================================================================================================

def get_default_config():
    default_config = {
        "StartingLine": 1,
        "platform_blue_M1": (64, 13),
        "platform_red_M1": (131, 13),
        "platform_blue_M2": (64, 78),
        "platform_red_M2": (131, 78),
        "StartLineSize": (20, 60),

        "sensor_window": (96, 26, 148, 192),
        "sensor_brightness": 0,
        "mouse_thres_int": (0, 50),
        "angle_requirement_deg": 40,

        "platform_cent_M1": (107, 62),
        "platform_cent_M2": (107, 87),
        "region_M1": (0, 4, 192, 72),
        "region_M2": (0, 76, 192, 70),
        "draw_M1": (0, 0, 0),
        "draw_M2": (100, 100, 100),
        "radius_M1_M2": (8, 8),

        "history_alpha_y": 0.985,
        "history_alpha_x": 0.83,

        "to_vflip": True,
        "to_transpose": True,
        "to_hmirror": False,
        "transpose_first": True,
        "median_blur": False,
        "debug": False,
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

def writeOpenMV(filename, config_dict):
    """Write a config dict to filename in the same format as read_config_file."""
    try:
        f = open(filename, "w")
        for key in config_dict:
            value = config_dict[key]
            # repr() keeps tuples, bools, etc. readable and parseable
            line = "{} = {}\n".format(key, repr(value))
            f.write(line)
        f.close()
        print("Configuration written to", filename)
    except OSError as e:
        print("Error writing to file", filename, e)
