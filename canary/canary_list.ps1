# Canary list shared by run_vivado_synth.ps1 and run_xsim.ps1.
# Top module and its files in compile order, relative to src/. Numbers match the harness and test/test.py.
# Each canary is its own top here, so c08 runs with its default ADD = 5 (the override is checked in CI only).
$Canaries = @(
    @{ Top = 'canary_baseline';      Files = @('canary_baseline.v') }                    # c00
    @{ Top = 'canary_ext_v';         Files = @('canary_ext_v.v') }                       # c01
    @{ Top = 'canary_logic';         Files = @('canary_logic.sv') }                      # c02
    @{ Top = 'canary_always_comb';   Files = @('canary_always_comb.sv') }                # c03
    @{ Top = 'canary_always_ff';     Files = @('canary_always_ff.sv') }                  # c04
    @{ Top = 'canary_enum';          Files = @('canary_enum.sv') }                       # c05
    @{ Top = 'canary_struct';        Files = @('canary_struct.sv') }                     # c06
    @{ Top = 'canary_package';       Files = @('canary_pkg.sv', 'canary_package.sv') }   # c07
    @{ Top = 'canary_param';         Files = @('canary_param.sv') }                      # c08
    @{ Top = 'canary_clog2';         Files = @('canary_clog2.sv') }                      # c09
    @{ Top = 'canary_generate';      Files = @('canary_generate.sv') }                   # c10
    @{ Top = 'canary_rom_case';      Files = @('canary_rom_case.sv') }                   # c11
    @{ Top = 'canary_rom_packed';    Files = @('canary_rom_packed.sv') }                 # c12
    @{ Top = 'canary_unique_case';   Files = @('canary_unique_case.sv') }                # c13
    @{ Top = 'canary_priority_case'; Files = @('canary_priority_case.sv') }              # c14
    @{ Top = 'canary_rom_unpacked';  Files = @('canary_rom_unpacked.sv') }               # c15
    @{ Top = 'canary_interface';     Files = @('canary_interface.sv') }                  # c16
)
