#!/bin/sh

#cat /proc/interrupts to find IRQ number of PCI-MSI iwlwifi: queueX
sudo echo "01" > /proc/irq/226/smp_affinity
sudo echo "02" > /proc/irq/227/smp_affinity
sudo echo "03" > /proc/irq/228/smp_affinity
sudo echo "04" > /proc/irq/229/smp_affinity


