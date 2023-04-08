# CL-JobsGarage

(This is an extanded version of CL-PoliceGarageV2)

**CL-JobsGarage** is a FiveM script that allows players to create an infinite amount of garages. These garages can be used to purchase, rent, and store vehicles, as well as change liveries and vehicle extras. The script uses a database table with a complete garage system and supports multiple jobs.

Preview : https://youtu.be/CHKa71cnI_g

# Features

- Purchase, rent, and store vehicles
- Change liveries and vehicle extras
- Complete garage system using a database table
- Use of compnay funds for buying vehicles
- Multiple job support
- Dynamic blips
- Highly configurable

# Configuration

You can configure the script using the `config.lua` file. The available options include:

- `UseLogs`: Set to `true` to enable Discord logs using the default QBCore logs system.
- `BanWhenExploit`: Set to `true` to ban players/cheaters (a safety feature).
- `DepotFine`: The amount of money the player needs to pay for depot. Set to `nil` to disable.
- `AutoRespawn`: Set to `true` to enable automatic respawn for all vehicles at available vehicles. If set to `false`, the script checks for missing vehicles to put in the vehicle depot.
- `CompanyFunds`: Set to `false` to disable the company funds feature (haven't been tested completely; not recommended to use). If enabled, the script checks for nearby - players within a specified radius.
- `UseBlips`: Set to `false` to disable all script blips.
- `RentMaximum`: The rent maximum allowed in minutes.
- `Target`: The name of your target.
- `FuelSystem`: The fuel system. The default value is `LegacyFuel`.
- `SetVehicleTransparency`: The vehicle transparency level for the preview. The available options are `low`, `medium`, `high`, and `none`.
- `Locals`: Contains various notification messages that the script uses. You can edit these messages to suit your needs.
- `Locations`: Contains information about the stations/garages available in the game. You can configure each station/garage's features and requirements here.

# Usage

To use CL-JobsGarage, simply install the script and start it. Players can then interact with the stations/garages you have configured to purchase, rent, and store vehicles.

# Contributing

Contributions are always welcome! If you find any issues or want to add new features, feel free to fork this repository and submit a pull request.

# Credits

CL-JobsGarage was developed by CloudDevelopment. Special thanks to the FiveM community as a whole and QBCore in particular for their contributions and support.

# License

This script is released under the GNU General Public License.
