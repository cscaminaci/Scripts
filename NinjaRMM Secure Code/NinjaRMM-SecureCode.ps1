# Generate a random 8-character security code using A-Z and 0-9
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
$code = -join ((1..8) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })

# Store the security code in NinjaRMM
Ninja-Property-Set secureCode $code

# Create the WPF window directly without using Start-Process
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore

# Create the XAML string first (not as XML)
$xamlString = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="Security Code"
    Width="400"
    Height="200"
    WindowStartupLocation="CenterScreen"
    Background="White"
    WindowStyle="ToolWindow">
    <Grid Margin="20">
        <StackPanel VerticalAlignment="Center">
            <TextBlock
                Text="This is your security code:"
                FontSize="16"
                Margin="0,0,0,10"
                TextAlignment="Center"/>
            <TextBlock
                Text="$code"
                FontSize="32"
                FontWeight="Bold"
                TextAlignment="Center"
                Foreground="#2196F3"/>
            <Button
                Name="OKButton"
                Content="OK"
                Width="100"
                Height="35"
                Margin="0,20,0,0"
                Background="#2196F3"
                Foreground="White"
                FontSize="14">
                <Button.Style>
                    <Style TargetType="Button">
                        <Style.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Background" Value="#1976D2"/>
                            </Trigger>
                        </Style.Triggers>
                    </Style>
                </Button.Style>
            </Button>
        </StackPanel>
    </Grid>
</Window>
"@

# Convert the string to XML after the replacement
[xml]$xaml = $xamlString

# Create the window
$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Add click handler for the OK button
$button = $window.FindName('OKButton')
$button.Add_Click({
    $window.Close()
})

# Show the window
$null = $window.ShowDialog()