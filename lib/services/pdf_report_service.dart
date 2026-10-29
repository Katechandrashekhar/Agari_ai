import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/fertilizer_recommendation.dart';
import '../models/soil_analysis.dart';

class PDFReportService {
  static Future<Uint8List> generateFertilizerReport({
    required FertilizerRecommendation recommendation,
    required SoilAnalysis soilAnalysis,
    String? farmerName,
  }) async {
    final pdf = pw.Document();

    // Use system fonts for better compatibility
    final ttf = await PdfGoogleFonts.openSansRegular();
    final boldTtf = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(farmerName ?? 'Farmer', boldTtf, ttf),
          pw.SizedBox(height: 20),

          // Soil Analysis Section
          _buildSoilAnalysisSection(soilAnalysis, boldTtf, ttf),
          pw.SizedBox(height: 20),

          // NPK Recommendations Section
          _buildNPKRecommendationsSection(recommendation, boldTtf, ttf),
          pw.SizedBox(height: 20),

          // Fertilizer Products Section
          _buildFertilizerProductsSection(recommendation, boldTtf, ttf),
          pw.SizedBox(height: 20),

          // Application Schedule Section
          _buildApplicationScheduleSection(recommendation, boldTtf, ttf),
          pw.SizedBox(height: 20),

          // Sustainability Metrics Section
          _buildSustainabilitySection(recommendation, boldTtf, ttf),
          pw.SizedBox(height: 20),

          // Footer
          _buildFooter(ttf),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(String farmerName, pw.Font boldFont, pw.Font regularFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.green200, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'AgriAI Fertilizer Recommendation Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  font: boldFont,
                  color: PdfColors.green800,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green600,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  'AI-Powered',
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: boldFont,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Farmer: $farmerName',
            style: pw.TextStyle(fontSize: 16, font: regularFont),
          ),
          pw.Text(
            'Generated: ${DateTime.now().toString().split('.')[0]}',
            style: pw.TextStyle(fontSize: 12, font: regularFont, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSoilAnalysisSection(SoilAnalysis analysis, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '🧪 Soil Analysis Results',
          style: pw.TextStyle(fontSize: 18, font: boldFont, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildAnalysisItem('Crop Type', analysis.cropType, boldFont, regularFont),
                  ),
                  pw.Expanded(
                    child: _buildAnalysisItem('Field Size', '${analysis.fieldSize} acres', boldFont, regularFont),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildAnalysisItem('pH Level', analysis.pH.toStringAsFixed(1), boldFont, regularFont),
                  ),
                  pw.Expanded(
                    child: _buildAnalysisItem('Organic Matter', '${analysis.organicMatter.toStringAsFixed(1)}%', boldFont, regularFont),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildAnalysisItem('Nitrogen (N)', '${analysis.nitrogen.toStringAsFixed(1)} kg/ha', boldFont, regularFont),
                  ),
                  pw.Expanded(
                    child: _buildAnalysisItem('Phosphorus (P)', '${analysis.phosphorus.toStringAsFixed(1)} kg/ha', boldFont, regularFont),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildAnalysisItem('Potassium (K)', '${analysis.potassium.toStringAsFixed(1)} kg/ha', boldFont, regularFont),
                  ),
                  pw.Expanded(
                    child: _buildAnalysisItem('Moisture', '${analysis.moistureContent.toStringAsFixed(1)}%', boldFont, regularFont),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAnalysisItem(String label, String value, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 12, font: boldFont, color: PdfColors.grey700),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, font: regularFont),
        ),
      ],
    );
  }

  static pw.Widget _buildNPKRecommendationsSection(FertilizerRecommendation recommendation, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '📊 NPK Recommendations',
          style: pw.TextStyle(fontSize: 18, font: boldFont, color: PdfColors.orange800),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              _buildNPKBar('Nitrogen (N)', recommendation.npkRecommendation.requiredNitrogen, PdfColors.blue, boldFont, regularFont),
              pw.SizedBox(height: 8),
              _buildNPKBar('Phosphorus (P)', recommendation.npkRecommendation.requiredPhosphorus, PdfColors.red, boldFont, regularFont),
              pw.SizedBox(height: 8),
              _buildNPKBar('Potassium (K)', recommendation.npkRecommendation.requiredPotassium, PdfColors.green, boldFont, regularFont),
              pw.SizedBox(height: 15),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.yellow50,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  'AI Analysis: Based on soil test results and crop requirements',
                  style: pw.TextStyle(fontSize: 12, font: regularFont),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildNPKBar(String nutrient, double value, PdfColor color, pw.Font boldFont, pw.Font regularFont) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            nutrient,
            style: pw.TextStyle(fontSize: 12, font: boldFont),
          ),
        ),
        pw.Expanded(
          child: pw.Container(
            height: 20,
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Container(
              width: (value / 100).clamp(0.0, 1.0) * 200, // Fixed width bar
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Text(
          '${value.toStringAsFixed(1)} kg/ha',
          style: pw.TextStyle(fontSize: 12, font: regularFont),
        ),
      ],
    );
  }

  static pw.Widget _buildFertilizerProductsSection(FertilizerRecommendation recommendation, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '🛒 Recommended Fertilizer Products',
          style: pw.TextStyle(fontSize: 18, font: boldFont, color: PdfColors.purple800),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Product Name', boldFont, isHeader: true),
                _buildTableCell('NPK Ratio', boldFont, isHeader: true),
                _buildTableCell('Quantity', boldFont, isHeader: true),
                _buildTableCell('Price', boldFont, isHeader: true),
              ],
            ),
            // Products
            ...recommendation.recommendedProducts.take(5).map((product) => pw.TableRow(
              children: [
                _buildTableCell(product.name, regularFont),
                _buildTableCell(product.npkComposition.npkRatio, regularFont),
                _buildTableCell('${product.recommendedQuantity} kg', regularFont),
                _buildTableCell('₹${product.pricePerKg.toStringAsFixed(0)}/kg', regularFont),
              ],
            )),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.green50,
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Text(
            'Total Estimated Cost: ₹${recommendation.estimatedCost.toStringAsFixed(0)}',
            style: pw.TextStyle(fontSize: 14, font: boldFont, color: PdfColors.green800),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          font: font,
          color: isHeader ? PdfColors.grey800 : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildApplicationScheduleSection(FertilizerRecommendation recommendation, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '📅 Application Schedule',
          style: pw.TextStyle(fontSize: 18, font: boldFont, color: PdfColors.teal800),
        ),
        pw.SizedBox(height: 10),
        ...recommendation.applicationSchedule.phases.map((phase) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    phase.name,
                    style: pw.TextStyle(fontSize: 14, font: boldFont, color: PdfColors.teal700),
                  ),
                  pw.Text(
                    'Day ${phase.dayFromPlanting}',
                    style: pw.TextStyle(fontSize: 12, font: regularFont, color: PdfColors.grey600),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Stage: ${phase.cropStage}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
              pw.Text(
                'Quantity: ${phase.quantity} kg/ha',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
              pw.Text(
                'Method: ${phase.method}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
              ),
            ],
          ),
        )),
      ],
    );
  }

  static pw.Widget _buildSustainabilitySection(FertilizerRecommendation recommendation, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '🌱 Sustainability Metrics',
          style: pw.TextStyle(fontSize: 18, font: boldFont, color: PdfColors.green800),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
            color: PdfColors.green50,
          ),
          child: pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSustainabilityMetric(
                    'Environmental Score',
                    '${recommendation.sustainabilityMetrics.environmentalScore}/100',
                    boldFont,
                    regularFont,
                  ),
                  _buildSustainabilityMetric(
                    'Water Efficiency',
                    '${recommendation.sustainabilityMetrics.waterEfficiency.toStringAsFixed(1)}L/kg',
                    boldFont,
                    regularFont,
                  ),
                  _buildSustainabilityMetric(
                    'Soil Health Impact',
                    '${recommendation.sustainabilityMetrics.soilHealthImpact}/100',
                    boldFont,
                    regularFont,
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Sustainability Factors: ${recommendation.sustainabilityMetrics.sustainabilityFactors.join(", ")}',
                style: pw.TextStyle(fontSize: 12, font: regularFont),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSustainabilityMetric(String label, String value, pw.Font boldFont, pw.Font regularFont) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, font: boldFont, color: PdfColors.green700),
        ),
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 10, font: regularFont, color: PdfColors.grey600),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Font regularFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'This report is generated by AgriAI\'s advanced artificial intelligence system.',
            style: pw.TextStyle(fontSize: 10, font: regularFont, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'For best results, follow the application schedule and monitor soil conditions regularly.',
            style: pw.TextStyle(fontSize: 10, font: regularFont, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '© 2025 AgriAI - Empowering Farmers with AI Technology',
            style: pw.TextStyle(fontSize: 10, font: regularFont, color: PdfColors.grey500),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Future<void> savePDF(Uint8List pdfBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName.pdf');
      await file.writeAsBytes(pdfBytes);
      print('PDF saved to: ${file.path}');
    } catch (e) {
      print('Error saving PDF: $e');
      throw Exception('Failed to save PDF: $e');
    }
  }

  static Future<void> printPDF(Uint8List pdfBytes) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      print('Error printing PDF: $e');
      throw Exception('Failed to print PDF: $e');
    }
  }

  static Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$fileName.pdf',
      );
    } catch (e) {
      print('Error sharing PDF: $e');
      throw Exception('Failed to share PDF: $e');
    }
  }
}