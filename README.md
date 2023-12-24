# MICS6000H Project - Expr2Netlist

## Environment Setup

### Haskell Environment

This project requires Haskell to be installed. The easiest way to install Haskell is to use the [Haskell Platform](https://www.haskell.org/downloads/). The project was developed using `GHC 9.2.8`, `cabal 3.6.2.0-p1` and `Stack 2.11.1`. I used `GHCup 0.1.20.0` to configure `GHC`, `cabal` and `Stack`.

You need to configure the rest of the environment by running the following commands:

```bash
cabal update # optional
cabal install --lib xml # optional
cabal install --lib tasty tasty-hunit # optional
cabal install --lib parsec
cabal install --lib boolsimplifier # optional
```

### ABC

Configure ABC for expression simplification and mapping. The following commands will clone the ABC repository and build it.

```bash
git clone --depth 1 https://github.com/berkeley-abc/abc
cd abc
make
```

### SIS (optional)

Configure SIS to compare the results with ABC. The following commands will clone the SIS repository and build it.

```bash
sudo apt install -y make gcc bison flex build-essential
wget https://github.com/JackHack96/logic-synthesis/archive/SIS.tar.gz
tar xzvf SIS.tar.gz
cd logic-synthesis-SIS
./configure prefix=xxx/build # replace xxx with the path to the project directory
make
make install
```

### Opentimer

OpenTimer is used for area cost calculation. The following commands will clone the OpenTimer repository and build it.

```bash
git clone --depth 1 https://github.com/OpenTimer/OpenTimer.git
cd OpenTimer
mkdir build
cd build
cmake ../
make 
```


## Usage

After you have configured the environment, you can run the project by executing the following command:

```bash
./run.sh
```

It will ask you to enter the boolean expression. You can enter the expression in the following format:

```
Enter the expression: a && b
```

The program will ask you to optimize the expression by using ABC or SIS. You can enter `abc` or `sis` to optimize the expression. 

```
Enter the output file name (e.g., output.eqn):
EQN saved to output.eqn
Choose the optimization tool:
1) ABC
2) SIS
Select an option (1/2): 
```

The optimization script for ABC can be checked in `scripts/abc_opt.sh`. The optimization script for SIS can be found in `run.sh` (basically, it calls the commands we have mentioned in slide `Multi-Level Logic Synthesis p55`)

```
sweep; eliminate -1
simplify -m nocomp
eliminate -1
sweep; eliminate 5 
simplify -m nocomp
resub -a
fx
resub -a; sweep
eliminate -1; sweep
full_simplify -m nocomp
```

ABC used the scripts mentioned in [Utah's ECE5740](https://my.ece.utah.edu/~kalla/ECE5740/hw5.pdf)

```
aig; bidec; st; resyn;
resyn2; write_blif ABC_opt.blif;
```

After the optimization, the program will map the optimized expression to the library file `INVNANDNOR.lib` and generate the netlist `opt.v`, with a area cost report.

```
Optimization and area calculation completed.
Area Cost: 5
Saved netlist path: opt.v
BLIF file path: ABC_opt.blif
EQN file path: output.eqn
Time: 0h:07m:13s   
```

You can tune the SIS optimization scripts in `run.sh` and ABC's optimization scripts in `scripts/abc_opt.sh` , and compare the results and just play with it.

Before and after you run the `run.sh`, you better run the `clean.sh` to clean up the project.

```bash
./clean.sh
```

## Liberty File

For liberty, I just put a simple one with INV, NAND and NOR gates. You can find it in `INVNANDNOR.lib`. You can also use your own liberty file. Just make sure the name of the file is `INVNANDNOR.lib`.

Some cost I pre-defined in the liberty file:

* INV: 1
* NAND: 2
* NOR: 3

## File Structure

```
├── abc --> ABC logic synthesis tool
├── abc.rc --> ABC command script
├── clean.sh --> Script to clean up the project
├── EqnGenerator --> Haskell program to generate equations
├── INVNANDNOR.lib --> Library file for logic synthesis
├── logic-synthesis-SIS --> SIS logic synthesis tool
├── OpenTimer --> OpenTimer timing analysis tool
├── opt.v --> Optimized netlist
├── output.eqn --> Converted equations
├── README.md
├── run.sh --> Script to run the project
├── scripts --> Scripts for logic synthesis
└── TestResults --> Test cases and results
```
