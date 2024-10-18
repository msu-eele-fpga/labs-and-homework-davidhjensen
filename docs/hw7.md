# HW 7 - Linux CLI practice

## Below are the problems, copy-and-pasted in. I confirm that the work is my own.

### Problem 1
`wc -w lorem-ipsum.txt`
```
296 lorem-ipsum.txt
```

### Problem 2
`wc -c lorem-ipsum.txt `
```
2069 lorem-ipsum.txt
```

### Problem  3
`wc -l lorem-ipsum.txt `
```
20 lorem-ipsum.txt
```

### Problem 4
`sort -h file-sizes.txt`
```
TONS OF STUFF with last one being 72G
```

### Problem 5
`sort -hr file-sizes.txt`
```
TONS OF STUFF with last ones being 0
```

### Problem 6
`cut -d',' -f3 log.csv`
```
ip
116.49.145.124
235.43.71.244
70.31.14.16
242.79.114.52
74.252.223.119
154.10.128.241
5.130.43.62
196.192.210.226
71.161.187.155
27.212.115.89
74.148.105.122
105.157.228.65
127.247.103.17
230.216.133.98
248.181.246.119
64.51.105.249
204.32.243.160
44.165.162.10
166.191.169.122
42.208.215.59
```

### Problem 7
`cut -d',' -f2-3 log.csv `
```
date,ip
1985-12-29T03:45:48.331Z,116.49.145.124
1975-08-19T08:27:05.166Z,235.43.71.244
1980-02-04T23:15:47.711Z,70.31.14.16
2005-12-03T20:51:09.797Z,242.79.114.52
1988-06-26T20:35:52.990Z,74.252.223.119
1987-12-19T06:43:46.252Z,154.10.128.241
2016-06-06T10:04:17.183Z,5.130.43.62
2020-07-09T06:34:53.526Z,196.192.210.226
1971-10-06T14:02:07.833Z,71.161.187.155
1991-01-26T01:05:28.571Z,27.212.115.89
1971-05-01T07:54:01.223Z,74.148.105.122
2004-07-13T14:00:56.930Z,105.157.228.65
2008-07-09T02:01:31.445Z,127.247.103.17
1988-07-12T20:42:46.031Z,230.216.133.98
1977-11-11T17:31:47.427Z,248.181.246.119
1971-11-01T11:10:22.790Z,64.51.105.249
1972-09-05T08:09:49.900Z,204.32.243.160
2020-05-01T10:07:36.210Z,44.165.162.10
1971-04-14T11:42:50.344Z,166.191.169.122
1984-02-07T17:10:40.523Z,42.208.215.59
```

### Problem 8
`cut -d',' -f1,4 log.csv`
``` 
uuid,country
13UVM9UZGVC5Z8FH,Australia
2YROM18LXGZE5S6N,Cuba
FQZ53Q6D7V1XQI2V,Uzbekistan
TQDOY14O1BIR3PYI,Dominica
MT4MGZ893KXD4KRH,Bangladesh
A9HVXMGXVZSL1GAQ,Iceland
MHQ2ER2D3943YJMD,Estonia
NZBNXUQHYNY0RZL4,Peru
NEIOCVYTTBRIV10Z,Central African Rep
MUE3QLVGTDNXZE6N,Gambia
QI5QGZ25IV8NDFGQ,Sri Lanka
23L2N1QFFZD06VCH,Lebanon
563Q79MGHAXQDSD1,Gambia
KRKGL80HNJ3VBKME,Italy
I7OFKV2DZPH26FNS,Uruguay
U7GR4CY8KDEA84JC,Jordan
DQ0CAYCQ92N6U0LN,Maldives
SVFJHHHJN30ULVBI,Gambia
013FDZ7LOUVSPIUZ,Uganda
JAPIFTQIGG4MXMQU,Australia
```

### Problem 9
`head -n 3 gibberish.txt `
```
To be: that we end to sleep of so long a life;
for who would fardels bear thought, and the oppressor's wrong,
about the natural shocks the slings and enterprises of dispriz'd lose ills we have,
```

### Problem 10
`tail -n 2 gibberish.txt`
```
for in the rub;
open for whose thought, and the insolence to suffer the name of off this quietus makes
```

### Problem 11
`tail -n +2 log.csv `
```
13UVM9UZGVC5Z8FH,1985-12-29T03:45:48.331Z,116.49.145.124,Australia
2YROM18LXGZE5S6N,1975-08-19T08:27:05.166Z,235.43.71.244,Cuba
FQZ53Q6D7V1XQI2V,1980-02-04T23:15:47.711Z,70.31.14.16,Uzbekistan
TQDOY14O1BIR3PYI,2005-12-03T20:51:09.797Z,242.79.114.52,Dominica
MT4MGZ893KXD4KRH,1988-06-26T20:35:52.990Z,74.252.223.119,Bangladesh
A9HVXMGXVZSL1GAQ,1987-12-19T06:43:46.252Z,154.10.128.241,Iceland
MHQ2ER2D3943YJMD,2016-06-06T10:04:17.183Z,5.130.43.62,Estonia
NZBNXUQHYNY0RZL4,2020-07-09T06:34:53.526Z,196.192.210.226,Peru
NEIOCVYTTBRIV10Z,1971-10-06T14:02:07.833Z,71.161.187.155,Central African Rep
MUE3QLVGTDNXZE6N,1991-01-26T01:05:28.571Z,27.212.115.89,Gambia
QI5QGZ25IV8NDFGQ,1971-05-01T07:54:01.223Z,74.148.105.122,Sri Lanka
23L2N1QFFZD06VCH,2004-07-13T14:00:56.930Z,105.157.228.65,Lebanon
563Q79MGHAXQDSD1,2008-07-09T02:01:31.445Z,127.247.103.17,Gambia
KRKGL80HNJ3VBKME,1988-07-12T20:42:46.031Z,230.216.133.98,Italy
I7OFKV2DZPH26FNS,1977-11-11T17:31:47.427Z,248.181.246.119,Uruguay
U7GR4CY8KDEA84JC,1971-11-01T11:10:22.790Z,64.51.105.249,Jordan
DQ0CAYCQ92N6U0LN,1972-09-05T08:09:49.900Z,204.32.243.160,Maldives
SVFJHHHJN30ULVBI,2020-05-01T10:07:36.210Z,44.165.162.10,Gambia
013FDZ7LOUVSPIUZ,1971-04-14T11:42:50.344Z,166.191.169.122,Uganda
JAPIFTQIGG4MXMQU,1984-02-07T17:10:40.523Z,42.208.215.59,Australia
```

### Problem 12
`grep -i -n -o 'and' gibberish.txt`
``` 
2:and
3:and
4:and
5:and
5:and
6:and
6:and
8:and
```

### Problem 13
`grep -inow 'we' gibberish.txt `
```
1:we
3:we
```

### Problem 14
`grep -oPi 'to [a-z]+' gibberish.txt`
```
To be
to sleep
to die
to take
to suffer
```

### Problem 15
`grep -ciP 'fpgas' fpgas.txt`
```
4
```

### Problem 16
`grep -iP '\b\w*(ot|ower|ile)' fpgas.txt`
```
FPGAs are hot.
FPGAs are not.
Software engineers cower,
Few have climbed the tower.
Years gone by, nary a smile,
First design to compile.
```

### Problem 17
`grep -iPc '^ *[--]' hdl/*/*.vhd`
```
hdl/async-conditioner/async_conditioner.vhd:1
hdl/async-conditioner/debouncer.vhd:0
hdl/async-conditioner/one_pulse.vhd:3
hdl/async-conditioner/synchronizer.vhd:0
hdl/led-patterns/LED_patterns.vhd:9
hdl/led-patterns/clock_gen.vhd:8
hdl/led-patterns/led_patterns_avalon.vhd:3
hdl/led-patterns/pat_gen_0.vhd:0
hdl/led-patterns/pat_gen_1.vhd:0
hdl/led-patterns/pat_gen_2.vhd:0
hdl/led-patterns/pat_gen_3.vhd:0
hdl/led-patterns/pat_gen_4.vhd:0
hdl/synchronizer/synchronizer.vhd:0
hdl/timed_counter/timed_counter.vhd:3
hdl/vending-machine/vending_machine.vhd:0
```

### Problem 18
`ls > ls-output.txt`
```
cat ls-output.txt
file-sizes.txt
fpgas.txt
gibberish.txt
log.csv
lorem-ipsum.txt
```

### Problem 19

`sudo dmesg | grep -iP 'CPU topo'
```
NOTHING SHOWED UP
```

### Problem 20

`ls Desktop/labs-and-homework-davidhjensen/hdl/*/*.vhd | grep -ciP '.vhd'`
```
15
```

### Problem 21
`grep -iP '(--)+' ./*/*.vhd | wc -l`
```
28
```

### Problem 22
`grep -inP 'FPGAs' fpgas.txt | cut -d':' -f1 `
```
1
2
4
8
```

### Problem 23
`du -h * | sort -hr | head -n 3`
```
12M	quartus/lab2
12M	quartus
8.5M	quartus/lab2/simulation/questa
```