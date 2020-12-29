# This file inludes the test set for coding 

@testset "Coding" begin
    # Fields 
    @test hasfield(GrayCoding, :pairs)

    # Construction 
    @test_throws Exception GrayCoding(3) 
    @test_throws Exception GrayCoding(7) 
    coding = GrayCoding(4) 
    coding = GrayCoding(8)

    # Check bit to symbol mapping 
    coding = GrayCoding(4) 
    @test coding.pairs[[0, 0]] == 1
    @test coding.pairs[[0, 1]] == 2
    @test coding.pairs[[1, 1]] == 3
    @test coding.pairs[[1, 0]] == 4
    
    # Check bit stream mapping 
    bits = [0, 1, 1, 1, 1, 1, 0, 0, 1, 0]
    symbols = coding(bits)
    @test symbols == [2, 3, 3, 1, 4]
end