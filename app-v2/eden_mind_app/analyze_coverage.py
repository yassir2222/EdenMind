
import os

def parse_lcov(file_path):
    files = []
    current_file = {}
    with open(file_path, 'r') as f:
        for line in f:
            if line.startswith('SF:'):
                current_file = {'file': line[3:].strip(), 'lines': 0, 'covered': 0}
            elif line.startswith('DA:'):
                current_file['lines'] += 1
                if not line.split(',')[1].strip() == '0':
                    current_file['covered'] += 1
            elif line.startswith('end_of_record'):
                # Calculate percentages
                total = current_file['lines']
                covered = current_file['covered']
                missed = total - covered
                current_file['missed'] = missed
                current_file['percent'] = (covered / total * 100) if total > 0 else 0
                files.append(current_file)
    return files

def main():
    lcov_path = 'coverage/lcov.info'
    if not os.path.exists(lcov_path):
        print("coverage/lcov.info not found.")
        return

    files = parse_lcov(lcov_path)
    # Sort by number of missed lines (highest impact first)
    files.sort(key=lambda x: x['missed'], reverse=True)

    with open('coverage_report.txt', 'w', encoding='utf-8') as report:
        report.write(f"{'File':<60} | {'Missed':<6} | {'Total':<6} | {'Coverage':<8}\n")
        report.write("-" * 90 + "\n")
        for f in files[:20]: # Top 20
            report.write(f"{f['file']:<60} | {f['missed']:<6} | {f['lines']:<6} | {f['percent']:.1f}%\n")
    print("Report written to coverage_report.txt")

if __name__ == '__main__':
    main()
