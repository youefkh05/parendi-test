#!/usr/bin/env python3

import glob
import os
import shutil
import subprocess
import statistics
import csv
import sys


# Path to this script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Repository root (one level above RTL_test/)
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))

# Parendi / Verilator paths
VERILATOR = os.path.join(REPO_ROOT, "bin", "verilator")
OBJ_DIR = os.path.join(REPO_ROOT, "obj_dir")

# Output location (local to RTL_test)
RESULTS_DIR = os.path.join(SCRIPT_DIR, "results")

def clean_obj_dir():
    if os.path.exists(OBJ_DIR):
        shutil.rmtree(OBJ_DIR)
    os.makedirs(OBJ_DIR)


def run_parendi(verilog_file):
    top = os.path.splitext(os.path.basename(verilog_file))[0]

    if not os.path.isfile(VERILATOR):
        raise RuntimeError(f"Verilator not found at {VERILATOR}")

    cmd = [
    	VERILATOR,
    	"--cc", verilog_file,
    	"--top-module", top,
    	"--threads", "1",
    	"-Wno-fatal",
    	"-Wno-WIDTHTRUNC",
    	"-Wno-WIDTHEXPAND",
    	"-Wno-SELRANGE",
    	"-Wno-CASEINCOMPLETE"
    ]



    subprocess.run(cmd, check=True)


def extract_depset_files():
    return glob.glob(os.path.join(OBJ_DIR, "*DepSet*__0.cpp"))

def count_lines(file_path):
    with open(file_path, "r") as f:
        return sum(1 for _ in f)

def main():
    if len(sys.argv) != 2:
        print("Usage: extract_parendi <rtl_file.v>")
        sys.exit(1)

    rtl_file = sys.argv[1]
    base = os.path.splitext(os.path.basename(rtl_file))[0]
    output_csv = os.path.join(RESULTS_DIR, f"{base}_fibers.csv")

    os.makedirs(RESULTS_DIR, exist_ok=True)

    print("✔ Cleaning obj_dir")
    clean_obj_dir()

    print(f"✔ Running Parendi on {rtl_file}")
    run_parendi(rtl_file)

    depset_files = extract_depset_files()
    if not depset_files:
        print("❌ No DepSet files found")
        sys.exit(1)

    fiber_sizes = [(os.path.basename(f), count_lines(f)) for f in depset_files]
    sizes = [s for _, s in fiber_sizes]
    stats = {
        "num_fibers-concurrency_degree": len(sizes),
        "mean_fiber_size-avg_partition_workload": statistics.mean(sizes),
        "max_fiber_size-worst_case_partition_cost": max(sizes),
        "min_fiber_size": min(sizes),
        "std_fiber_size-load_variance": statistics.stdev(sizes) if len(sizes) > 1 else 0.0,
        "imbalance_ratio-parallel_efficiency_risk": max(sizes) / statistics.mean(sizes)
    }

    print("\n=== Parendi Fiber Statistics ===")
    for k, v in stats.items():
        if isinstance(v, float):
            print(f"{k:45s}: {v:.4f}")
        else:
            print(f"{k:45s}: {v}")

    print("→ Writing CSV:", output_csv)
    with open(output_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["Metric", "Value"])

    print("✔ Writing CSV:", output_csv)
    with open(output_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["Metric", "Value"])
        for k, v in stats.items():
            writer.writerow([k, v])

        writer.writerow([])
        writer.writerow(["Fiber Name", "Lines of Code"])
        for name, size in fiber_sizes:
            writer.writerow([name, size])

    print("✅ Done")

if __name__ == "__main__":
    main()

